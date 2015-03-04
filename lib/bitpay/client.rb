# license Copyright 2011-2014 BitPay, Inc., MIT License
# see http://opensource.org/licenses/MIT
# or https://github.com/bitpay/php-bitpay-client/blob/master/LICENSE

require 'uri'
require 'net/https'
require 'json'

require_relative 'key_utils'

module BitPay
  # This class is used to instantiate a BitPay Client object. It is expected to be thread safe.
  #
  module SDK
    class Client
      
      # @return [Client]
      # @example
      #  # Create a client with a pem file created by the bitpay client:
      #  client = BitPay::SDK::Client.new
      def initialize(opts={})
        @pem                = opts[:pem] || ENV['BITPAY_PEM'] || KeyUtils.generate_pem 
        @key                = KeyUtils.create_key @pem
        @priv_key           = KeyUtils.get_private_key @key
        @pub_key            = KeyUtils.get_public_key @key
        @client_id          = KeyUtils.generate_sin_from_pem @pem
        @uri                = URI.parse opts[:api_uri] || API_URI
        @user_agent         = opts[:user_agent] || USER_AGENT
        @https              = Net::HTTP.new @uri.host, @uri.port
        @https.use_ssl      = true
        @https.open_timeout = 10
        @https.read_timeout = 10

        @https.ca_file      = CA_FILE
        @tokens             = opts[:tokens] || {}

        # Option to disable certificate validation in extraordinary circumstance.  NOT recommended for production use
        @https.verify_mode = opts[:insecure] == true ? OpenSSL::SSL::VERIFY_NONE : OpenSSL::SSL::VERIFY_PEER
        
        # Option to enable http request debugging
        @https.set_debug_output($stdout) if opts[:debug] == true
      end

      ## Pair client with BitPay service
      # => Pass empty hash {} to retreive client-initiated pairing code
      # => Pass {pairingCode: 'WfD01d2'} to claim a server-initiated pairing code
      #
      def pair_client(params={})
        pairing_request(params)
      end

      ## Compatibility method for pos pairing
      #
      def pair_pos_client(claimCode)
        raise BitPay::ArgumentError, "pairing code is not legal" unless verify_claim_code(claimCode)
        pair_client({pairingCode: claimCode})
      end

      ## Create bitcoin invoice
      #
      #   Defaults to pos facade, also works with merchant facade
      # 
      def create_invoice(price:, currency:, facade: 'pos', params:{})
        raise BitPay::ArgumentError, "Illegal Argument: Price must be formatted as a float" unless 
          price.is_a?(Numeric) ||
          /^[[:digit:]]+(\.[[:digit:]]{2})?$/.match(price) ||
          currency == 'BTC' && /^[[:digit:]]+(\.[[:digit:]]{1,6})?$/.match(price)
        raise BitPay::ArgumentError, "Illegal Argument: Currency is invalid." unless /^[[:upper:]]{3}$/.match(currency)
        params.merge!({price: price, currency: currency})
        response = send_request("POST", "invoices", facade: facade, params: params)
        response["data"]
      end

      ## Gets the privileged merchant-version of the invoice
      #   Requires merchant facade token
      #
      def get_invoice(id:)
        response = send_request("GET", "invoices/#{id}", facade: 'merchant')
        response["data"]        
      end
      
      ## Gets the public version of the invoice
      #
      def get_public_invoice(id:)
        request = Net::HTTP::Get.new("/invoices/#{id}")
        response = process_request(request)
        response["data"]
      end
      
      ## Checks that the passed tokens are valid by
      #  comparing them to those that are authorized by the server
      #
      #  Uses local @tokens variable if no tokens are passed
      #  in order to validate the connector is properly paired
      #
      def verify_tokens(tokens: @tokens)
        server_tokens = refresh_tokens
        tokens.each{|key, value| return false if server_tokens[key] != value}
        return true
      end
      
      ## Generates REST request to api endpoint
      # =>  Defaults to merchant facade unless token or facade is explicitly provided
      #
      def send_request(verb, path, facade: 'merchant', params: {}, token: nil)
        token ||= get_token(facade)

        # Verb-specific logic
        case verb.upcase
          when "GET"
            urlpath = '/' + path + '?token=' + token
            request = Net::HTTP::Get.new urlpath
            request['X-Signature'] = KeyUtils.sign(@uri.to_s + urlpath, @priv_key)

          when "PUT"

          when "POST"  # Requires a GUID

            urlpath = '/' + path
            request = Net::HTTP::Post.new urlpath
            params[:token] = token
            params[:guid]  = SecureRandom.uuid
            params[:id] = @client_id
            request.body = params.to_json
            request['X-Signature'] = KeyUtils.sign(@uri.to_s + urlpath + request.body, @priv_key)

          when "DELETE"
         
            raise(BitPayError, "Invalid HTTP verb: #{verb.upcase}")
        end

        # Build request headers and submit
        request['X-Identity'] = @pub_key
   
        response = process_request(request)
      end

  ##### PRIVATE METHODS #####
      private

      ## Processes HTTP Request and returns parsed response
      # Otherwise throws error
      #
      def process_request(request)

        request['User-Agent'] = @user_agent
        request['Content-Type'] = 'application/json'
        request['X-BitPay-Plugin-Info'] = 'Rubylib' + VERSION

        begin
          response = @https.request request
        rescue => error
          raise BitPay::ConnectionError, "#{error.message}"
        end

        if response.kind_of? Net::HTTPSuccess
          return JSON.parse(response.body)
        elsif JSON.parse(response.body)["error"]
          raise(BitPayError, "#{response.code}: #{JSON.parse(response.body)['error']}")
        else
          raise BitPayError, "#{response.code}: #{JSON.parse(response.body)}"
        end
          
      end

      ## Fetches the tokens hash from the server and
      #  updates @tokens
      #
      def refresh_tokens
        urlpath = '/tokens'

        request = Net::HTTP::Get.new(urlpath)
        request['X-Identity'] = @pub_key
        request['X-Signature'] = KeyUtils.sign(@uri.to_s + urlpath, @priv_key)

        response = process_request(request)
        token_array = response["data"] || {}

        tokens = {}
        token_array.each do |t|
          tokens[t.keys.first] = t.values.first
        end

        @tokens = tokens
        return tokens

      end

      ## Makes a request to /tokens for pairing
      #     Adds passed params as post parameters
      #     If empty params, retrieves server-generated pairing code
      #     If pairingCode key/value is passed, will pair client ID to this account
      #   Returns response hash
      #
      def pairing_request(params)
        urlpath = '/tokens'
        request = Net::HTTP::Post.new urlpath
        params[:guid] = SecureRandom.uuid
        params[:id] = @client_id
        request.body = params.to_json
        process_request(request)
      end

      def get_token(facade)
        token = @tokens[facade] || refresh_tokens[facade] || raise(BitPayError, "Not authorized for facade: #{facade}")
      end

      def verify_claim_code(claim_code)
        regex = /^[[:alnum:]]{7}$/
        matches = regex.match(claim_code)
        !(matches.nil?)
      end
    end
  end
end

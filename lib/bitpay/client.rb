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
  class Client
    

    # @return [Client]
    # @example
    #  # Create a client with a pem file created by the bitpay client:
    #  client = BitPay::Client.new
    def initialize(opts={})
      @pem               = opts[:pem] || ENV['BITPAY_PEM'] || KeyUtils.retrieve_or_generate_pem 
      @key               = KeyUtils.create_key @pem
      @priv_key          = KeyUtils.get_private_key @key
      @pub_key           = KeyUtils.get_public_key @key
      @client_id         = KeyUtils.generate_sin_from_pem @pem
      @uri               = URI.parse opts[:api_uri] || API_URI
      @user_agent        = opts[:user_agent] || USER_AGENT
      @https             = Net::HTTP.new @uri.host, @uri.port
      @https.use_ssl     = true
      @https.ca_file     = CA_FILE
      @tokens            = {}

      # Option to disable certificate validation in extraordinary circumstance.  NOT recommended for production use
      @https.verify_mode = opts[:insecure] == true ? OpenSSL::SSL::VERIFY_NONE : OpenSSL::SSL::VERIFY_PEER
      
      # Option to enable http request debugging
      @https.set_debug_output($stdout) if opts[:debug] == true

    end

    def pair_pos_client(claimCode)
      response = set_pos_token(claimCode)
      get_token 'pos'
      response
    end

    def create_invoice(id:, price:, currency:, facade: 'pos', params:{})
      params.merge!({price: price, currency: currency})
      response = send_request("POST", "invoices", facade: facade, params: params)
      response["data"]
    end

    def get_public_invoice(id:)
      request = Net::HTTP::Get.new("/invoices/#{id}")
      response = process_request(request)
      response["data"]
    end
    
    ## Generates REST request to api endpoint
    def send_request(verb, path, facade: 'merchant', params: {}, token: nil)
      token ||= get_token(facade)

      # Verb-specific logic
      case verb.upcase
        when "GET"
          urlpath = '/' + path + '?nonce=' + KeyUtils.nonce + '&token=' + token
          request = Net::HTTP::Get.new urlpath
          request['X-Signature'] = KeyUtils.sign(@uri.to_s + urlpath, @priv_key)

        when "PUT"

        when "POST"  # Requires a GUID

          urlpath = '/' + path
          request = Net::HTTP::Post.new urlpath
          params[:token] = token
          params[:nonce] = KeyUtils.nonce
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

      response = @https.request request

      if response.kind_of? Net::HTTPSuccess
        return JSON.parse(response.body)
      elsif JSON.parse(response.body)["error"]
        raise(BitPayError, "#{response.code}: #{JSON.parse(response.body)['error']}")
      else
        raise BitPayError, "#{response.code}: #{JSON.parse(response.body)}"
      end
        
    end

    ## Requests token by appending nonce and signing URL
    #  Returns a hash of available tokens
    #
    def load_tokens

      urlpath = '/tokens?nonce=' + KeyUtils.nonce

      request = Net::HTTP::Get.new(urlpath)
      request['x-identity'] = @pub_key
      request['x-signature'] = KeyUtils.sign(@uri.to_s + urlpath, @priv_key)

      response = process_request(request)

      token_array = response["data"] || {}

      tokens = {}
      token_array.each do |t|
        tokens[t.keys.first] = t.values.first
      end

      @tokens = tokens
      return tokens

    end

    ## Retrieves specified token from hash, otherwise tries to refresh @tokens and retry
    def set_pos_token(claim_code)
      params = {pairingCode: claim_code}
      urlpath = '/tokens'
      request = Net::HTTP::Post.new urlpath
      params[:guid] = SecureRandom.uuid
      params[:id] = @client_id
      request.body = params.to_json
      process_request(request)
    end

    def get_token(facade)
      token = @tokens[facade] || load_tokens[facade] || raise(BitPayError, "Not authorized for facade: #{facade}")
    end

  end
end

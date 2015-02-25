# license Copyright 2011-2015 BitPay, Inc., MIT License
# see http://opensource.org/licenses/MIT
# or https://github.com/bitpay/php-bitpay-client/blob/master/LICENSE

require 'uri'
require 'net/https'
require 'json'

require_relative 'key_utils'
require_relative 'rest_connector'

module BitPay
  # This class is used to instantiate a BitPay Client object. It is expected to be thread safe.
  #
  module SDK
    class Client
      include BitPay::RestConnector 
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
        post(path: 'tokens', params: params)
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
        token = get_token(facade)
        post(path: "invoices", token: token, params: params)
      end

      ## Gets the public version of the invoice
      #
      def get_public_invoice(id:)
        get(path: "invoices/#{id}", public: true)
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

      private

      def verify_claim_code(claim_code)
        regex = /^[[:alnum:]]{7}$/
          matches = regex.match(claim_code)
        !(matches.nil?)
      end
    end
  end
end

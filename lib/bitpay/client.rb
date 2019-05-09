# license Copyright 2011-2019 BitPay, Inc., MIT License
# see http://opensource.org/licenses/MIT
# or https://github.com/bitpay/php-bitpay-client/blob/master/LICENSE

require 'uri'
require 'net/https'
require 'json'

require 'bitpay_key_utils'
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
        tokens = post(path: 'tokens', params: params)
        return tokens["data"]
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
        invoice = post(path: "invoices", token: token, params: params)
        invoice["data"]
      end

      ## Gets the privileged merchant-version of the invoice		
      #   Requires merchant facade token		
      #		
      def get_invoice(id:)
        token = get_token('merchant')
        invoice = get(path: "invoices/#{id}", token: token)
        invoice["data"]
      end

      ## Gets the public version of the invoice
      #
      def get_public_invoice(id:)
        invoice = get(path: "invoices/#{id}", public: true)
        invoice["data"]
      end
      
      
      ## Refund paid BitPay invoice
      #
      #   If invoice["data"]["flags"]["refundable"] == true the a refund address was 
      #   provided with the payment and the refund_address parameter is an optional override
      #  
      #   Amount and Currency are required fields for fully paid invoices but optional
      #   for under or overpaid invoices which will otherwise be completely refunded
      #
      #   Requires merchant facade token
      #
      #  @example
      #    client.refund_invoice(id: 'JB49z2MsDH7FunczeyDS8j', params: {amount: 10, currency: 'USD', bitcoinAddress: '1Jtcygf8W3cEmtGgepggtjCxtmFFjrZwRV'})
      #
      def refund_invoice(id:, params:{})
        invoice = get_invoice(id: id)
        refund = post(path: "invoices/#{id}/refunds", token: invoice["token"], params: params)
        refund["data"]
      end
      
      ## Get All Refunds for Invoice
      #   Returns an array of all refund requests for a specific invoice, 
      # 
      #   Requires merchant facade token
      #
      #  @example:
      #    client.get_all_refunds_for_invoice(id: 'JB49z2MsDH7FunczeyDS8j')
      #
      def get_all_refunds_for_invoice(id:)
        urlpath = "invoices/#{id}/refunds"
        invoice = get_invoice(id: id)
        refunds = get(path: urlpath, token: invoice["token"])
        refunds["data"]
      end

      ## Get Refund
      #   Requires merchant facade token
      #
      #  @example:
      #    client.get_refund(id: 'JB49z2MsDH7FunczeyDS8j', request_id: '4evCrXq4EDXk4oqDXdWQhX')
      #
      def get_refund(invoice_id:, request_id:)
        urlpath = "invoices/#{invoice_id}/refunds/#{request_id}"
        invoice = get_invoice(id: invoice_id)
        refund = get(path: urlpath, token: invoice["token"])
        refund["data"]
      end
      
      ## Cancel Refund
      #   Requires merchant facade token
      #
      #  @example:
      #    client.cancel_refund(id: 'JB49z2MsDH7FunczeyDS8j', request_id: '4evCrXq4EDXk4oqDXdWQhX')
      #
      def cancel_refund(invoice_id:, request_id:)
        urlpath = "invoices/#{invoice_id}/refunds/#{request_id}"
        refund = get_refund(invoice_id: invoice_id, request_id: request_id)
        deletion = delete(path: urlpath, token: refund["token"])
        deletion["data"]
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

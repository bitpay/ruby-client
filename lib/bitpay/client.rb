require 'uri'
require 'net/https'
require 'json'

module BitPay
  # This class is used to instantiate a BitPay Client object. It is expected to be thread safe.
  #
  # @example
  #  # Create a client with your BitPay API key (obtained from the BitPay API access page at BitPay.com):
  #  client = BitPay::Client.new 'YOUR_API_KEY'
  class Client
    class BitPayError < StandardError; end

    # Creates a BitPay Client object. The second parameter is a hash for overriding defaults.
    #
    # @return [Client]
    # @example
    #  # Create a client with your BitPay API key (obtained from the BitPay API access page at BitPay.com):
    #  client = BitPay::Client.new 'YOUR_API_KEY'
    def initialize(api_key, opts={})
      @api_key           = api_key
      @uri               = URI.parse opts[:api_uri] || API_URI
      @https             = Net::HTTP.new @uri.host, @uri.port
      @https.use_ssl     = true
      @https.ca_file     = CA_FILE


      # Option to disable certificate validation in extraordinary circumstance.  NOT recommended for production use
      @https.verify_mode = opts[:insecure] == true ? OpenSSL::SSL::VERIFY_NONE : OpenSSL::SSL::VERIFY_PEER

    end

    # Makes a GET call to the BitPay API.
    # @return [Hash]
    # @see get_invoice
    # @example
    #  # Get an invoice:
    #  existing_invoice = client.get 'invoice/YOUR_INVOICE_ID'
    def get(path)
      request = Net::HTTP::Get.new @uri.path+'/'+path
      request.basic_auth @api_key, ''
      request['User-Agent'] = USER_AGENT
      response = @https.request request
      JSON.parse response.body
    end

    # Makes a POST call to the BitPay API.
    # @return [Hash]
    # @see create_invoice
    #  # Create an invoice:
    #  created_invoice = client.post 'invoice', {:price => 1.45, :currency => 'BTC'}
    def post(path, params={})

      request = Net::HTTP::Post.new @uri.path+'/'+path
      request.basic_auth @api_key, ''
      request['User-Agent'] = USER_AGENT
      request['Content-Type'] = 'application/json'
      request['X-BitPay-Plugin-Info'] = 'Rubylib' + VERSION
      request.body = params.to_json
      response = @https.request request
      JSON.parse response.body
    end
  end
end

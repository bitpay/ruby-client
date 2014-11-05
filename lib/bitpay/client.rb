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
      request(Net::HTTP::Get, path)
    end

    # Makes a POST call to the BitPay API.
    # @return [Hash]
    # @see create_invoice
    #  # Create an invoice:
    #  created_invoice = client.post 'invoice', {:price => 1.45, :currency => 'BTC'}
    def post(path, params={})
      request(Net::HTTP::Post, path, params)
    end

    private

    def request(request_klass, path, params=nil)
      request  = make_request(request_klass, path, params)
      response = @https.request(request)
      raise BitPayError, "HTTP Status " + response.code + " with body: " + response.body unless response.kind_of?(Net::HTTPSuccess)
      return JSON.parse(response.body)
    rescue => e
      fail BitPayError, "Bitpay Request Error: #{e}"
    end

    def make_request(request_klass, path, params)
      request_klass.new(@uri.path + '/' + path).tap do |r|
        r.basic_auth @api_key, ''
        r['User-Agent']           = USER_AGENT
        r['Content-Type']         = 'application/json'
        r['X-BitPay-Plugin-Info'] = 'Rubylib' + VERSION
        r.body = params.to_json if params
      end
    end
  end
end

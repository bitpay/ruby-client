module BitPay
  class Client
    class BitPayError < StandardError; end

    def initialize(api_key, opts={})
      @api_key           = api_key
      @uri               = URI.parse opts[:api_url] || API_URI
      @https             = Net::HTTP.new @uri.host, @uri.port
      @https.use_ssl     = true
      @https.cert        = OpenSSL::X509::Certificate.new File.read(opts[:cert] || CERT)
      @https.key         = OpenSSL::PKey::RSA.new File.read(opts[:key] || KEY)
      @https.verify_mode = OpenSSL::SSL::VERIFY_PEER
    end

    def get(path)
      request = Net::HTTP::Get.new @uri.path+'/'+path
      request.basic_auth @api_key, ''
      request['User-Agent'] = USER_AGENT
      response = @https.request request
      JSON.parse response.body
    end

    def post(path, params={})
      request = Net::HTTP::Post.new @uri.path+'/'+path
      request.basic_auth @api_key, ''
      request['User-Agent'] = USER_AGENT
      request.body = params
      response = @https.request request
      JSON.parse response.body
    end
  end
end

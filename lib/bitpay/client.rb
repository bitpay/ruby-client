require 'uri'
require 'net/https'
require 'json'

require_relative 'key_utils'

module BitPay
  # This class is used to instantiate a BitPay Client object. It is expected to be thread safe.
  #
  # @example
  #  # Create a client with your BitPay API key (obtained from the BitPay API access page at BitPay.com):
  #  client = BitPay::Client.new 'YOUR_API_KEY'
  class Client
    

    # Creates a BitPay Client object. The second parameter is a hash for overriding defaults.
    #
    # @return [Client]
    # @example
    #  # Create a client with your BitPay API key (obtained from the BitPay API access page at BitPay.com):
    #  client = BitPay::Client.new 'YOUR_API_KEY'
    def initialize(opts={})
      # TODO:  Think about best way to store keys
      @priv_key          = opts[:priv_key] || ENV['PRIV_KEY'] || (raise BitPayError, MISSING_KEY)
      @pub_key           = KeyUtils.get_public_key(@priv_key)
      @client_id         = KeyUtils.get_client_id(@priv_key)
      @uri               = URI.parse opts[:api_uri] || API_URI
      @user_agent        = opts[:user_agent] || USER_AGENT
      @https             = Net::HTTP.new @uri.host, @uri.port
      @https.use_ssl     = true
      @https.ca_file     = CA_FILE

      # Option to disable certificate validation in extraordinary circumstance.  NOT recommended for production use
      @https.verify_mode = opts[:insecure] == true ? OpenSSL::SSL::VERIFY_NONE : OpenSSL::SSL::VERIFY_PEER
      
      # Option to enable http request debugging
      @https.set_debug_output($stdout) if opts[:debug] == true

      # Load all the available tokens into @tokens
      load_tokens      
    end

    def pair_pos_client(claimCode)
      response = set_pos_token(claimCode)
      case response.code
      when "200"
        get_token 'pos'
      when "500"
        raise BitPayError, JSON.parse(response.body)["error"]
      else
        raise BitPayError, "#{response.code}: #{JSON.parse(response.body)}"
      end
      response
    end

    def create_invoice(id:, price:, currency:, facade: 'pos')
      response = send_request("POST", "invoices", facade: facade, params: {price: price, currency: currency})
      response["data"]
    end

    def get_public_invoice(id:)
      request = Net::HTTP::Get.new("/invoices/#{id}")
      response = @https.request request
      (JSON.parse response.body)["data"]
    end
    
    ## Generates REST request to api endpoint
    def send_request(verb, path, facade: 'merchant', params: {}, token: nil)
      token ||= @tokens[facade] || raise(BitPayError, "No token for specified facade: #{facade}")

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
        else 
          raise(BitPayError, "Invalid HTTP verb: #{verb.upcase}")
      end

      # Build request headers and submit
      request['User-Agent'] = @user_agent
      request['Content-Type'] = 'application/json'
      request['X-BitPay-Plugin-Info'] = 'Rubylib' + VERSION
      request['X-Identity'] = @pub_key
 
      response = @https.request request
      JSON.parse response.body
    end

##### COMPATIBILITY METHODS #####

    ## Provided for legacy compatibility with old library
    #
    def get(path, facade="pos")
      send_request("GET", path, facade: facade)
    end

    ## Provided for legacy compatibility with old library
    #
    def post(path, params={}, facade="pos")
      send_request("POST", path, facade: facade, params: params)
    end

##### PRIVATE METHODS #####
    private

    ## Requests token by appending nonce and signing URL
    #  Returns a hash of available tokens
    #
    def load_tokens

      urlpath = '/tokens?nonce=' + KeyUtils.nonce

      request = Net::HTTP::Get.new(urlpath)
      request['content-type'] = "application/json"
      request['user-agent'] = @user_agent
      request['x-identity'] = @pub_key
      request['x-signature'] = KeyUtils.sign(@uri.to_s + urlpath, @priv_key)

      response = @https.request request

      # /tokens returns an array of hashes.  Let's turn it into a more useful single hash
      token_array = JSON.parse(response.body)["data"] || {}

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
      request['User-Agent'] = @user_agent
      request['Content-Type'] = 'application/json'
      request['X-BitPay-Plugin-Info'] = 'Rubylib' + VERSION
      @https.request request
    end

    def get_token(facade)
      token = @tokens[facade] || load_tokens[facade] || raise(BitPayError, "Not authorized for facade: #{facade}")
    end

  end
end

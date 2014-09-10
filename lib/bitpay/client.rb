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
      @SIN               = KeyUtils.get_sin(@priv_key)
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

    ## Generates REST request to api endpoint
    def send_request(verb, path, facade='merchant', params={})
      token = @tokens[facade] || raise(BitPayError, "No token for specified facade: #{facade}")

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
      send_request("GET", path, facade)
    end

    ## Provided for legacy compatibility with old library
    #
    def post(path, params={}, facade="pos")
      send_request("POST", path, facade, params)
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
    def get_token(facade)
      token = @tokens[facade] || load_tokens[facade] || raise(BitPayError, "Not authorized for facade: #{facade}")
    end

  end
end

require 'uri'
require 'net/https'
require 'json'
require 'ecdsa'
require 'securerandom'
require 'digest/sha2'

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
    def initialize(opts={})
      # TODO:  Think about best way to store keys
      @pub_key           = ENV['pubkey']
      @priv_key          = ENV['privkey']
      @uri               = URI.parse opts[:api_uri] || API_URI
      @user_agent        = opts[:user_agent] || USER_AGENT
      @https             = Net::HTTP.new @uri.host, @uri.port
      @https.use_ssl     = true
      @https.ca_file     = CA_FILE

      # Option to disable certificate validation in extraordinary circumstance.  NOT recommended for production use
      @https.verify_mode = opts[:insecure] == true ? OpenSSL::SSL::VERIFY_NONE : OpenSSL::SSL::VERIFY_PEER

      # TODO:  How do I choose facade
      @token             = get_token('merchant')

    end

    # Makes a GET call to the BitPay API.
    # @return [Hash]
    # @see get_invoice
    # @example
    #  # Get an invoice:
    #  existing_invoice = client.get 'invoice/YOUR_INVOICE_ID'
    def get(path)
      url = @uri.path + '/' + path + '?nonce=' + Time.now.strftime('%Y%m%d%H%M%S%L') + '&token=' + @token
      request = Net::HTTP::Get.new url
      
      request['User-Agent'] = @user_agent
      request['Content-Type'] = 'application/json'
      request['X-BitPay-Plugin-Info'] = 'Rubylib' + VERSION
      request['X-PubKey'] = @pub_key
      request['X-Signature'] = sign(url, @priv_key.to_i(16))

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
      request.body = build_bitauth_message(params)
      
      request['User-Agent'] = @user_agent
      request['Content-Type'] = 'application/json'
      request['X-BitPay-Plugin-Info'] = 'Rubylib' + VERSION
      request['X-PubKey'] = @pub_key
      request['X-Signature'] = sign(request.body, @priv_key.to_i(16))
 
      response = @https.request request
      JSON.parse response.body
    end

    ## Generates a SIN based on public and private keys
    #  Can be passed public and private keys or will use pub/private key from file-system by default
    #
    def generate_sin_from_keypair(params={})
    end

    ## Generates a keypair and associated SIN
    #
    def generate_keypair_and_sin
    end


##### PRIVATE METHODS #####
    private

    ## Adds token and nonce to message body
    #
    def build_bitauth_message(message)
      puts "in bitauthbuild"
      message[:token] = @token
      message[:nonce] = Time.now.strftime('%Y%m%d%H%M%S%L')
      puts message.inspect
      message.to_json

    end

    ## Requests token
    #
    def get_token(facade)
      # TODO: Assemble this from endpoint var
      url = 'https://test.bitpay.com/tokens?nonce=' + Time.now.strftime('%Y%m%d%H%M%S%L')
      xsignature = sign(url,@priv_key.to_i(16))

      request = Net::HTTP::Get.new url
      request['User-Agent'] = @user_agent
      request['X-PubKey'] = @pub_key
      request['X-Signature'] = sign(url, @priv_key.to_i(16))
    
      response = @https.request request
    
      token = JSON.parse(response)
      token = token["data"].select { |item| item.has_key?(facade)}.first[facade]
      raise SecurityError,"You do not have permission for the specified facade" if token == nil 
      puts "token is #{token}"
      return token
    end

    ## 
    #
    def sign(message,private_key)
      group = ECDSA::Group::Secp256k1
      digest = Digest::SHA256.digest(message)
      signature = nil
      while signature.nil?
        temp_key = 1 + SecureRandom.random_number(group.order - 1)
        signature = ECDSA.sign(group, private_key, digest, temp_key)              
      end
      return ECDSA::Format::SignatureDerString.encode(signature).unpack("H*").first
    end
  end
end

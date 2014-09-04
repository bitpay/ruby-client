require 'uri'
require 'net/https'
require 'json'
require 'ecdsa'
require 'securerandom'
require 'digest/sha2'

# dev dependencies
require 'pry'

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
      @pub_key           = opts[:pub_key] || ENV['pubkey'].strip || raise(BitPayError)  # should be able to compute this
      @priv_key          = opts[:priv_key] || ENV['privkey'].strip || raise(BitPayError)
      @SIN               = ENV['SIN'] || raise(BitPayError, "No SIN found") # should be able to compute this
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
          urlpath = '/' + path + '?nonce=' + nonce + '&token=' + token
          request = Net::HTTP::Get.new urlpath
          request['X-Signature'] = sign(@uri.to_s + urlpath)

        when "PUT"

        when "POST"  # Requires a GUID

          urlpath = '/' + path
          request = Net::HTTP::Post.new urlpath
          params[:token] = token
          params[:nonce] = nonce
          params[:guid]  = SecureRandom.uuid
          request.body = params.to_json
          request['X-Signature'] = sign(@uri.to_s + urlpath + request.body)

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
    def get(path)
      send_request("GET", path)
    end

    ## Provided for legacy compatibility with old library
    #
    def post(path, params={})
      send_request("POST", path, 'merchant', params)
    end

##### CLASS METHODS #####

    def self.get_public_key
    end

    ## Generates a SIN from private key
    def self.get_sin
      #http://blog.bitpay.com/2014/07/01/bitauth-for-decentralized-authentication.html
      #https://en.bitcoin.it/wiki/Identity_protocol_v1

      # NOTE:  All Digests are calculated against the binary representation, 
      # hence the requirement to use [].pack("H*")
      
      group = ECDSA::Group::Secp256k1
      
      #Generate Private Key
      #private_key = 1 + SecureRandom.random_number(group.order - 1)
      private_key = ENV["privkey"].to_i(16)      

      #Generate Public Key
      public_key = group.generator.multiply_by_scalar(private_key)
      public_key_string_compressed = ECDSA::Format::PointOctetString.encode(public_key, compression:true)
      puts "Public Key: #{public_key_string_compressed.unpack("H*").first}" 
      
      # Step 1: SHA-256 of Public Key
      step_one = Digest::SHA256.hexdigest(public_key_string_compressed)  # Works when PK is in binary format
      #puts "step_one: #{step_one}"

      # Step 2: RIPEMD-160 of Step 1
      step_two = Digest::RMD160.hexdigest([step_one].pack("H*")) 
      #puts "step_two #{step_two}"

      # Step 3: Version + SIN TYPE + Step 2
      step_three = "0F02" + step_two
      #puts "step_three: #{step_three}"

      # Step 4: Double SHA-256 of Step 3
      step_four = Digest::SHA256.hexdigest([Digest::SHA256.hexdigest([step_three].pack("H*"))].pack("H*"))
      #puts "step_four: #{step_four}"

      # Step 5: Checksum (first 8 chars)
      step_five = step_four[0..7]
      #puts "step_five: #{step_five}"

      # Step 6: Step 3 + Step 5
      step_six = step_three + step_five
      #puts "step_six: #{step_six}"

      # Step 7: Base58 Encode
      step_seven = encode_base58(step_six)
      #puts "step_seven: #{step_seven}"

      # Return the SIN
      return step_seven
      
    end


##### PRIVATE METHODS #####
    private

    ## Generate a new nonce based on UTC timestamp
    #
    def nonce
      Time.now.utc.strftime('%Y%m%d%H%M%S%L')
    end

    ## Requests token by appending nonce and signing URL
    #  Returns a hash of available tokens
    #
    def load_tokens

      urlpath = '/tokens?nonce=' + nonce

      request = Net::HTTP::Get.new(urlpath)
      request['content-type'] = "application/json"
      request['user-agent'] = @user_agent
      request['x-identity'] = @pub_key
      request['x-signature'] = sign(@uri.to_s + urlpath)

      response = @https.request request

      # /tokens returns an array of hashes.  Let's turn it into a more useful single hash
      token_array = JSON.parse(response.body)["data"]

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

    ## Generate ECDSA signature
    #
    def sign(message)
      group = ECDSA::Group::Secp256k1
      digest = Digest::SHA256.digest(message)
      signature = nil
      while signature.nil?
        temp_key = 1 + SecureRandom.random_number(group.order - 1)
      signature = ECDSA.sign(group, @priv_key.to_i(16), digest, temp_key)
      
      return ECDSA::Format::SignatureDerString.encode(signature).unpack("H*").first
      end
    end

    ## Base58 Encoding Method
    #
    def self.encode_base58 (data) 
      code_string = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
      base = 58

      x = data.hex
      
      output_string = ""

      while x > 0 do
        remainder = x % base
        x = x / base
        output_string << code_string[remainder]
      end

      pos = 0
      
      while data[pos,2] == "00" do
        output_string << code_string[0]
        pos += 2
      end

     output_string.reverse()
    end

  end
end

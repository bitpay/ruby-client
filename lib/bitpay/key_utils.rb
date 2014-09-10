require 'uri'
require 'net/https'
require 'json'
require 'ecdsa'
require 'securerandom'
require 'digest/sha2'
require 'cgi'
require 'pry'

module BitPay
  class KeyUtils
    
      @@group = ECDSA::Group::Secp256k1
    
      def self.nonce
        Time.now.utc.strftime('%Y%m%d%H%M%S%L')
      end

      def self.generate_private_key
        1 + SecureRandom.random_number(@@group.order - 1)
      end

      ## Gets private key from ENV variable or local FS
      #
      def self.get_local_private_key
        ENV['PRIV_KEY'] || (raise BitPayError, MISSING_KEY)
        # TODO: add a file-system option at ~/.bitpay/api.key
      end
      
      def self.get_public_key(private_key_hex=get_local_private_key) 
        private_key = private_key_hex.to_i(16)
        public_key = @@group.generator.multiply_by_scalar(private_key)
        public_key_string_compressed = ECDSA::Format::PointOctetString.encode(public_key, compression:true)
        # Return Hex string
        public_key_string_compressed.unpack("H*").first
      end
  
      ## Generates a SIN from private key
      def self.get_sin(private_key_hex=get_local_private_key)
        #http://blog.bitpay.com/2014/07/01/bitauth-for-decentralized-authentication.html
        #https://en.bitcoin.it/wiki/Identity_protocol_v1
  
        # NOTE:  All Digests are calculated against the binary representation, 
        # hence the requirement to use [].pack("H*") to convert to binary for each step
        
        #Generate Private Key
        public_key  = [get_public_key(private_key_hex)].pack("H*")
        
        # Step 1: SHA-256 of Public Key
        step_one = Digest::SHA256.hexdigest(public_key)
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

    ## Generates a registration request URL
    #
    def self.generate_registration_url(uri,label,facade,sin)
      #https://test.bitpay.com/api-access-request?label=node-bitpay-client-HamPay.local&id=Tezeb3ToLu2tVnAhQED8FENDgVkHp4RKXBj&facade=merchant
      url = uri + BitPay::CLIENT_REGISTRATION_PATH + 
           "?label=" + CGI::escape(label) +
           "&id=" + sin +
           "&facade=" + facade

      return url
      
    end
      
      ## Generate ECDSA signature
      #
      def self.sign(message, privkey)
        group = ECDSA::Group::Secp256k1
        digest = Digest::SHA256.digest(message)
        signature = nil
        while signature.nil?
          temp_key = 1 + SecureRandom.random_number(group.order - 1)
        signature = ECDSA.sign(group, privkey.to_i(16), digest, temp_key)
        
        return ECDSA::Format::SignatureDerString.encode(signature).unpack("H*").first
        end
      end
  
########## Private Class Methods ################
  
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
      private_class_method :encode_base58
  
    end
  end
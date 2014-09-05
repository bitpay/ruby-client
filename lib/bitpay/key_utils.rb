require 'json'
require 'ecdsa'
require 'securerandom'
require 'digest/sha2'
module BitPay
  class KeyUtils
      def self.nonce
        Time.now.utc.strftime('%Y%m%d%H%M%S%L')
      end
      
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
        step_one = Digest::SHA256.hexdigest(public_key_string_compressed)
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
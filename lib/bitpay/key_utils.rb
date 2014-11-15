# license Copyright 2011-2014 BitPay, Inc., MIT License
# see http://opensource.org/licenses/MIT
# or https://github.com/bitpay/php-bitpay-client/blob/master/LICENSE

require 'uri'
require 'net/https'
require 'json'
require 'openssl'
require 'ecdsa'
require 'securerandom'
require 'digest/sha2'
require 'cgi'

module BitPay
  class KeyUtils
    class << self
      def nonce
        Time.now.utc.strftime('%Y%m%d%H%M%S%L')
      end

      ## Generates a new private key and writes to local FS
      #
      def retrieve_or_generate_pem
        begin
          pem = get_local_pem_file
        rescue
          pem = generate_pem
        end
        pem
      end

      def generate_pem
        key = OpenSSL::PKey::EC.new("secp256k1")
        key.generate_key
        write_pem_file(key)
        key.to_pem
      end

      def create_key pem
        OpenSSL::PKey::EC.new(pem)
      end

      def create_new_key
        key = OpenSSL::PKey::EC.new("secp256k1")
        key.generate_key
        key
      end

      def write_pem_file key
        FileUtils.mkdir_p(BITPAY_CREDENTIALS_DIR)
        File.open(PRIVATE_KEY_PATH, 'w') { |file| file.write(key.to_pem) }
      end
      ## Gets private key from ENV variable or local FS
      #
      def get_local_pem_file
        ENV['BITPAY_PEM'] || File.read(PRIVATE_KEY_PATH) || (raise BitPayError, MISSING_KEY)
      end
    
      def get_private_key key
        key.private_key.to_int.to_s(16)
      end

      def get_public_key key 
        key.public_key.group.point_conversion_form = :compressed
        key.public_key.to_bn.to_s(16).downcase
      end

      def get_private_key_from_pem pem
        raise BitPayError, MISSING_KEY unless pem
        key = OpenSSL::PKey::EC.new(pem)
        get_private_key key
      end

      def get_public_key_from_pem pem
        raise BitPayError, MISSING_KEY unless pem
        key = OpenSSL::PKey::EC.new(pem)
        get_public_key key
      end

      def generate_sin_from_pem(pem = nil)
        #http://blog.bitpay.com/2014/07/01/bitauth-for-decentralized-authentication.html
        #https://en.bitcoin.it/wiki/Identity_protocol_v1

        # NOTE:  All Digests are calculated against the binary representation, 
        # hence the requirement to use [].pack("H*") to convert to binary for each step
        
        #Generate Private Key
        key = OpenSSL::PKey::EC.new(pem ||= get_local_pem_file)
        key.public_key.group.point_conversion_form = :compressed
        public_key = key.public_key.to_bn.to_s(2)
        step_one = Digest::SHA256.hexdigest(public_key)
        step_two = Digest::RMD160.hexdigest([step_one].pack("H*")) 
        step_three = "0F02" + step_two
        step_four_a = Digest::SHA256.hexdigest([step_three].pack("H*"))
        step_four = Digest::SHA256.hexdigest([step_four_a].pack("H*"))
        step_five = step_four[0..7]
        step_six = step_three + step_five
        encode_base58(step_six)
      end
      
      
    ## Generate ECDSA signature
    #  This is the last method that requires the ecdsa gem, which we would like to replace

      def sign(message, privkey)
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
      private
      def encode_base58 (data) 
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
end

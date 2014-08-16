# license Copyright 2011-2014 BitPay, Inc., MIT License
# see http://opensource.org/licenses/MIT
# or https://github.com/bitpay/php-bitpay-client/blob/master/LICENSE

require 'rubygems'
require 'commander/import'

program :name, 'BitPay Ruby Library CLI'
program :version, BitPay::VERSION
program :description, 'Official BitPay Ruby API Client.  Use to securely register your client with the BitPay API endpoint. '
program :help_formatter, :compact
 
command :pair do |c|
  c.syntax = 'bitpay pair <code>'
  c.summary = "Pair the local keys to a bitpay account."
  c.option '--test', "Use the bitpay test server"
  c.option '--custom <custom>',  "Use a custom bitpay URI"
  c.option '--insecure <insecure>', "Use an insecure custom bitpay URI"
  c.action do |args, options| 
    raise ArgumentError, "Pairing failed, please call argument as 'bitpay pair <code> [options]'" unless args.first
    case
    when options.test
      client = BitPay::Client.new(api_uri: "https://test.bitpay.com")
      message = "Paired with test.bitpay.com"
    when options.custom
      client = BitPay::Client.new(api_uri: options.custom)
      message = "Paired with #{options.custom}"
    when options.insecure
      client = BitPay::Client.new(insecure: true, api_uri: options.insecure)
      message = "Paired with #{options.insecure}"
    else
      client = BitPay::Client.new
      message = "Paired with bitpay.com"
    end

    begin
      client.pair_pos_client args.first
      puts message
    rescue Exception => e
      puts e.message
    end
  end
end

command :show_keys do |c|
  c.syntax = 'bitpay show_keys'
  c.summary = "Read current environment's key information to STDOUT"
  c.description = ''
  c.example 'description', 'command example'
  c.action do |args, options|
    
    pem         = BitPay::KeyUtils.get_local_pem_file
    private_key = BitPay::KeyUtils.get_private_key_from_pem pem
    public_key  = BitPay::KeyUtils.get_public_key_from_pem pem
    client_id   = BitPay::KeyUtils.generate_sin_from_pem pem
    
    puts "Current BitPay Client Keys:\n"
    puts "Private Key:  #{private_key}"
    puts "Public Key:   #{public_key}"
    puts "Client ID:    #{client_id}"
    
  end
end

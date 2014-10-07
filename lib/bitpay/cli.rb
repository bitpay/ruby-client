# license Copyright 2011-2014 BitPay, Inc., MIT License
# see http://opensource.org/licenses/MIT
# or https://github.com/bitpay/php-bitpay-client/blob/master/LICENSE

require 'rubygems'
require 'commander/import'

program :name, 'BitPay Ruby Library CLI'
program :version, BitPay::VERSION
program :description, 'Official BitPay Ruby API Client.  Use to securely register your client with the BitPay API endpoint. '
program :help_formatter, :compact
 
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

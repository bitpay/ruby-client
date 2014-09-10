require 'rubygems'
require 'commander/import'

program :name, 'BitPay Ruby Library CLI'
program :version, BitPay::VERSION
program :description, 'Official BitPay Ruby API Client.  Use to securely register your client with the BitPay API endpoint. '
program :help_formatter, :compact
 
command :register_client do |c|
  c.syntax = 'bitpay register_client [options]'
  c.summary = 'Generate Keypair and submit registration request to specified API endpoint'
  c.description = ''
  c.example 'description', 'command example'
  c.option '--uri <uri>', 'API Endpoint URI to which the client should be registered'
  c.action do |args, options|
    options.default \
      :uri => "https://bitpay.com"
      
    #BitPay::KeyUtils.register_client
    puts options.uri
  end
end

command :show_keys do |c|
  c.syntax = 'bitpay show_keys'
  c.summary = "Read current environment's key information to STDOUT"
  c.description = ''
  c.example 'description', 'command example'
  c.action do |args, options|
    private_key   = BitPay::KeyUtils.get_local_private_key
    public_key    = BitPay::KeyUtils.get_public_key(private_key)
    sin           = BitPay::KeyUtils.get_sin(private_key)
    
    puts "Current BitPay Client Keys:\n"
    puts "Private Key:  #{private_key}"
    puts "Public Key:   #{public_key}"
    puts "SIN:          #{sin}"
    
  end
end
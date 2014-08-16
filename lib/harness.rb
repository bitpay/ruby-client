# license Copyright 2011-2014 BitPay, Inc., MIT License
# see http://opensource.org/licenses/MIT
# or https://github.com/bitpay/php-bitpay-client/blob/master/LICENSE

require_relative 'bitpay.rb'
require_relative 'bitpay/key_utils.rb'

# Test SIN Generation class methods

# Generate SIN
ENV["PRIV_KEY"] = "16d7c3508ec59773e71ae728d29f41fcf5d1f380c379b99d68fa9f552ce3ebc3"
puts "privkey: #{ENV['PRIV_KEY']}"
puts "target SIN: TfFVQhy2hQvchv4VVG4c7j4XPa2viJ9HrR8"
puts "Derived SIN: #{BitPay::KeyUtils.get_client_id}"

puts "\n\n------------------\n\n"

uri = "https://localhost:8088"
#name = "Ridonculous.label That shouldn't work really"
name = "somethinginnocuous"
facade = "pos"
client_id = BitPay::KeyUtils.get_client_id

BitPay::KeyUtils.generate_registration_url(uri,name,facade,client_id)

puts "\n\n------------------\n\n"

#### Test Invoice Creation using directly assigned keys 
## (Ultimately pubkey and SIN should be derived)

ENV["PRIV_KEY"] = "16d7c3508ec59773e71ae728d29f41fcf5d1f380c379b99d68fa9f552ce3ebc3"
#ENV["pub_key"] = "0353a036fb495c5846f26a3727a28198da8336ae4f5aaa09e24c14a4126b5d969d"
#ENV['SIN'] = "TfFVQhy2hQvchv4VVG4c7j4XPa2viJ9HrR8"

client = BitPay::Client.new({insecure: true, debug: false})

invoice = client.post 'invoices', {:price => 10.00, :currency => 'USD'}

puts "Here's the invoice: \n" + JSON.pretty_generate(invoice)


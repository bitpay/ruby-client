require_relative 'bitpay.rb'
require_relative 'bitpay/key_utils.rb'

# Test SIN Generation class methods

# Generate SIN
ENV["priv_key"] = "16d7c3508ec59773e71ae728d29f41fcf5d1f380c379b99d68fa9f552ce3ebc3"
puts "privkey: #{ENV['priv_key']}"
puts "target SIN: TfFVQhy2hQvchv4VVG4c7j4XPa2viJ9HrR8"
puts "Derived SIN: #{BitPay::KeyUtils.get_sin}"

puts "\n\n------------------\n\n"

#### Test Invoice Creation using directly assigned keys 
## (Ultimately pubkey and SIN should be derived)

ENV["priv_key"] = "16d7c3508ec59773e71ae728d29f41fcf5d1f380c379b99d68fa9f552ce3ebc3"
ENV["pub_key"] = "0353a036fb495c5846f26a3727a28198da8336ae4f5aaa09e24c14a4126b5d969d"
ENV['SIN'] = "TfFVQhy2hQvchv4VVG4c7j4XPa2viJ9HrR8"

client = BitPay::Client.new({insecure: true, debug: false})

invoice = client.post 'invoices', {:price => 10.00, :currency => 'USD'}

puts "Here's the invoice: \n" + JSON.pretty_generate(invoice)

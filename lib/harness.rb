require_relative 'bitpay.rb'

# From Bitpay Web generator
# ENV["pubkey"] = "0320ded0ab599f3722425ec3f24bbc91e587dc93cb807b729a3e57a1527fcdf464"
# ENV["privkey"] = "1f44e6a65f549c5e7efdda84af12480602e2926479ea1ebd19c8a7d55da218cc"
# ENV['SIN'] = "TfDEenRq7nNqUECzCHFgL6y3mRnNYtLvo9E"
# POS Token MRUUyvzUtMZq9R2YkZ2riM

# From Dev Hipchat - gives "Invalid Signature"
# ENV['SIN'] = "TfFVQhy2hQvchv4VVG4c7j4XPa2viJ9HrR8"
# ENV["privkey"] = "16d7c3508ec59773e71ae728d29f41fcf5d1f380c379b99d68fa9f552ce3ebc3"
# ENV["pubkey"] = "0353a036fb495c5846f26a3727a28198da8336ae4f5aaa09e24c14a4126b5d969d"
# POS Token: 64Qpw6gN4rSKLJb1LsfuR2E2P7QgEqGWY78RczNZung6

# From Node Client - Gives "Invalid Public Key"
# ENV['SIN'] = "Tezeb3ToLu2tVnAhQED8FENDgVkHp4RKXBj"
# ENV["privkey"] = "2CMdg5UtMhnGh4qcoerEeXegojbBkcojghPkxv9LiQjR89PkC71jKT8KE5crcyACjFngZskyCqtTv8eniWNGxyFiVd1vFnzC6DXSFLLSgFRPYc"
# ENV["pubkey"] = "Tezeb3ToLu2tVnAhQED8FENDgVkHp4RKXBj"

# From Dev Hipchat - gives "Invalid Signature"
 ENV['SIN'] = "TfFVQhy2hQvchv4VVG4c7j4XPa2viJ9HrR8"
 ENV["privkey"] = "16d7c3508ec59773e71ae728d29f41fcf5d1f380c379b99d68fa9f552ce3ebc3"
 ENV["pubkey"] = "0353a036fb495c5846f26a3727a28198da8336ae4f5aaa09e24c14a4126b5d969d"
# POS Token: 64Qpw6gN4rSKLJb1LsfuR2E2P7QgEqGWY78RczNZung6

client = BitPay::Client.new({insecure: true, debug: true})

invoice = client.post 'invoices', {:price => 10.00, :currency => 'USD'}

puts "Here's the invoice: \n" + JSON.pretty_generate(invoice)

#client.get
require_relative 'bitpay.rb'

ENV["pubkey"] = "0320ded0ab599f3722425ec3f24bbc91e587dc93cb807b729a3e57a1527fcdf464"
ENV["privkey"] = "1f44e6a65f549c5e7efdda84af12480602e2926479ea1ebd19c8a7d55da218cc"

# SIN TfDEenRq7nNqUECzCHFgL6y3mRnNYtLvo9E

client = BitPay::Client.new
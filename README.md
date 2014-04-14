# BitPay Library for Ruby [![](https://secure.travis-ci.org/bitpay/ruby-client.png)](http://travis-ci.org/bitpay/ruby-client)
Powerful, flexible, lightweight interface to the BitPay Bitcoin Payment Gateway API.

## Installation

    gem install bitpay-client
    
In your Gemfile:

    gem 'bitpay-client', :require => 'bitpay'

Or directly:

    require 'bitpay'

## Basic Usage

To create an invoice:

    client = BitPay::Client.new 'YOUR_API_KEY'
    invoice = client.post 'invoice', {:price => 10.00, :currency => 'USD'}

With invoice creation, `price` and `currency` are the only required fields. If you are sending a customer from your website to make a purchase, setting `redirectURL` is 

Response will be a hash with information on your newly created invoice. Send your customer to the `url` to complete payment:

    {
      "id"             => "DGrAEmbsXe9bavBPMJ8kuk", 
      "url"            => "https://bitpay.com/invoice?id=DGrAEmbsXe9bavBPMJ8kuk",
      "status"         => "new",
      "btcPrice"       => "0.0495",
      "price"          => 10,
      "currency"       => "USD",
      "invoiceTime"    => 1383265343674,
      "expirationTime" => 1383266243674,
      "currentTime"    => 1383265957613
    }

There are many options available when creating invoices, which are listed in the [BitPay API documentation](https://bitpay.com/bitcoin-payment-gateway-api).

To get updated information on this invoice, make a get call with the id returned:

    invoice = client.get 'invoice/DGrAEmbsXe9bavBPMJ8kuk'

## API Documentation

API Documentation is available on the [BitPay site](https://bitpay.com/bitcoin-payment-gateway-api).

## RDoc/YARD Documentation
The code has been fully code documented, and the latest version is always available at the [Rubydoc Site](http://rubydoc.info/gems/bitpay-client).

## Running the Tests

    $ bundle install
    $ bundle exec rake

In addition to a full test suite, there is Travis integration for MRI 1.9, JRuby and Rubinius.

## Found a bug?
Let us know! Send a pull request or a patch. Questions? Ask! We're here to help. We will respond to all filed issues.

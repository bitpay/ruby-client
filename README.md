# BitPay Library for Ruby [![](https://secure.travis-ci.org/bitpay/ruby-client.png)](http://travis-ci.org/bitpay/ruby-client)
Powerful, flexible, lightweight interface to the BitPay Bitcoin Payment Gateway API.

## Installation

    gem install bitpay-client
    
In your Gemfile:

    gem 'bitpay-client', :require => 'bitpay'

Or directly:

    require 'bitpay'

## Configuration

The bitpay client creates a cryptographically secure connection to your server by pairing an API code with keys stored on your server. The library generates the keys as a .pem file, which is stored in `$HOME/.bitpay/bitpay.pem` or preferentially in an environment variable.

The client will generate a key when initialized if one does not already exist.

## Basic Usage

### Pairing with Bitpay.com

To pair with bitpay.com you need to have an approved merchant account.  
1. Login to your account  
2. Navigate to bitpay.com/api-tokens (Dashboard > My Account > API Tokens)  
3. Copy an existing pairing code or create a new token and copy the pairing code.  
4. Use the bitpay command line tool to pair with bitpay.com `bitpay pair <pairing_code>`   

### To create an invoice with a paired client:

    client = BitPay::Client.new 
    invoice = client.create_invoice (id: <id>, price: <price>, currency: <currency>, facade: <facade>)

With invoice creation, `price` and `currency` are the only required fields. If you are sending a customer from your website to make a purchase, setting `redirectURL` will redirect the customer to your website when the invoice is paid.

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

    invoice = client.get_public_invoice(DGrAEmbsXe9bavBPMJ8kuk)'

## Testnet Usage

During development and testing, take advantage of the [Bitcoin TestNet](https://en.bitcoin.it/wiki/Testnet) by passing a custom `api_uri` option on initialization:

    BitPay::Client.new("myAPIKey", {api_uri: "https://test.bitpay.com/api"})
    
Note that in order to pair with testnet, you will need a pairing code from test.bitpay.com and will need to use the bitpay client with the --test option.

## API Documentation

API Documentation is available on the [BitPay site](https://bitpay.com/api).

## RDoc/YARD Documentation
The code has been fully code documented, and the latest version is always available at the [Rubydoc Site](http://rubydoc.info/gems/bitpay-client).

## Running the Tests
The tests require that environment variables be set for the bitpay server, user name, and password. First run:
    
    $ source ./spec/set_constants.sh https://test.bitpay.com <yourusername> <yourpassword>

    $ bundle install
    $ bundle exec rake

In addition to a full test suite, there is Travis integration for MRI 1.9, JRuby and Rubinius.

## Found a bug?
Let us know! Send a pull request or a patch. Questions? Ask! We're here to help. We will respond to all filed issues.

## Contributors
[Click here](https://github.com/bitpay/ruby-client/graphs/contributors) to see a list of the contributors to this library.

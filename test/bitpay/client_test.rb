require File.join File.dirname(__FILE__), '..', 'env.rb'

USER_AGENT = 'ruby-bitpay-client '+BitPay::VERSION

def invoice_create_body
  {:price => 1, :currency => 'USD'}
end

def invoice_response_body
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
end

def unauthorized_key_body
  {"error" => {"type" => "unauthorized", "message" => "invalid api key"}}
end

stub_request(:post, "https://KEY:@bitpay.com/api/invoice/create").
  with(
    :headers => {'User-Agent'=>USER_AGENT, 'Content-Type' => 'application/json'},
    :body => invoice_create_body
  ).
  to_return(:body => invoice_response_body.to_json)

stub_request(:get, "https://KEY:@bitpay.com/api/invoice/DGrAEmbsXe9bavBPMJ8kuk").
  with(:headers => {'User-Agent'=>USER_AGENT}).
  to_return(:body => invoice_response_body.to_json)

stub_request(:get, "https://KEY:@bitpay.com/api/invoice/BADAPIKEY").
  with(:headers => {'User-Agent'=>USER_AGENT}).
  to_return(:status => 403, :body => unauthorized_key_body.to_json)  

describe BitPay::Client do
  before do
    @client = BitPay::Client.new 'KEY'
  end

  describe 'post' do
    it 'creates invoice' do
      response = @client.post 'invoice/create', invoice_create_body
      response.class.must_equal Hash
      response['id'].must_equal 'DGrAEmbsXe9bavBPMJ8kuk'
    end
  end

  describe 'get' do
    it 'retreives invoice' do
      response = @client.get 'invoice/DGrAEmbsXe9bavBPMJ8kuk'
      response.class.must_equal Hash
      response['id'].must_equal 'DGrAEmbsXe9bavBPMJ8kuk'
    end
  end

  describe 'bad API Key' do
    it 'returns Error' do
      assert_raises(BitPay::Client::BitPayError) {
        response = @client.get 'invoice/BADAPIKEY'
      }
    end
  end  
end

require File.join File.dirname(__FILE__), '..', 'env.rb'

USER_AGENT = 'bitpay-ruby '+BitPay::VERSION

def invoice_body
  {"id"=>"DGrAEmbsXe9bavBPMJ8kuk", "url"=>"https://bitpay.com/invoice?id=DGrAEmbsXe9bavBPMJ8kuk", "status"=>"new", "btcPrice"=>"0.0495", "price"=>10, "currency"=>"USD", "invoiceTime"=>1383265343674, "expirationTime"=>1383266243674, "currentTime"=>1383265957613}
end

stub_request(:post, "https://KEY:@bitpay.com/api/invoice/create").
  with(:headers => {'User-Agent'=>USER_AGENT}).
  to_return(:body => invoice_body.to_json)

stub_request(:get, "https://KEY:@bitpay.com/api/invoice/DGrAEmbsXe9bavBPMJ8kuk").
  with(:headers => {'User-Agent'=>USER_AGENT}).
  to_return(:body => invoice_body.to_json)

describe BitPay::Client do
  before do
    @client = BitPay::Client.new 'KEY'
  end

  describe 'post' do
    it 'creates invoice' do
      response = @client.post 'invoice/create'
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
end
require 'spec_helper'

def tokens
    {"data" => 
      [{"merchant" => "MERCHANTTOKEN"},
      {"pos" =>"POSTOKEN"},
      {"merchant/invoice" => "9kv7gGqZLoQ2fxbKEgfgndLoxwjp5na6VtGSH3sN7buX"}
      ]
    }
end

describe BitPay::Client do
  let(:bitpay_client) { BitPay::Client.new({api_uri: BitPay::TEST_API_URI}) }

  before do
      allow(BitPay::KeyUtils).to receive(:nonce).and_return('1')
      stub_request(:get, /#{BitPay::TEST_API_URI}\/tokens.*/).to_return(:status => 200, :body => tokens.to_json, :headers => {})
  end

  describe "#initialize" do

    it 'should throw an error if no private key is provided' do
      expect {bitpay_client}.to raise_error(BitPay::BitPayError)
    end

    it 'should be able to get private key from the env' do
      stub_const('ENV', {'PRIV_KEY' => PRIV_KEY})
      expect {bitpay_client}.to_not raise_error
    end
    
  end

  describe "#send_request" do
    before do
      stub_const('ENV', {'PRIV_KEY' => PRIV_KEY})
    end

    context "GET" do    
      it 'should generate a get request' do
        stub_request(:get, /#{BitPay::TEST_API_URI}\/whatever.*/).to_return(:body => '{"awesome": "json"}')
        bitpay_client.send_request("GET", "whatever", "merchant")
        expect(WebMock).to have_requested(:get, "#{BitPay::TEST_API_URI}/whatever?nonce=1&token=MERCHANTTOKEN") 
      end
    end

    context "POST" do
        it 'should generate a post request' do
          stub_request(:post, /#{BitPay::TEST_API_URI}.*/).to_return(:body => '{"awesome": "json"}')
          bitpay_client.send_request("POST", "whatever", "merchant")
          expect(WebMock).to have_requested(:post, "#{BitPay::TEST_API_URI}/whatever")
        end
    end

  end
end

describe "Live Integration Testing" do
  let(:bitpay_client) { BitPay::Client.new({api_uri: BitPay::TEST_API_URI}) }

  ## These are live tests against https://test.bitpay.com
  #  It is assumed that the provided private key is already associated with
  #  an account which can create invoices
  #

  before do
    WebMock.allow_net_connect!
    stub_const('ENV', {'PRIV_KEY' => PRIV_KEY})
  end

  it 'should initialize without errors' do
    expect {bitpay_client}.to_not raise_error
  end

  it 'should be able to request an invoice' do
    invoice = bitpay_client.post 'invoices', {:price => 10.00, :currency => 'USD'}
    expect(invoice).to have_key("facade")
  end
  
end
  


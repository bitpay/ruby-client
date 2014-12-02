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

    it 'should be able to get pem file from the env' do
      stub_const('ENV', {'BITPAY_PEM' => PEM})
      expect {bitpay_client}.to_not raise_error
    end
    
  end

  describe "#send_request" do
    before do
      stub_const('ENV', {'BITPAY_PEM' => PEM})
    end

    context "GET" do    
      it 'should generate a get request' do
        stub_request(:get, /#{BitPay::TEST_API_URI}\/whatever.*/).to_return(:body => '{"awesome": "json"}')
        bitpay_client.send_request("GET", "whatever", facade: "merchant")
        expect(WebMock).to have_requested(:get, "#{BitPay::TEST_API_URI}/whatever?nonce=1&token=MERCHANTTOKEN") 
      end
    end

    context "POST" do
        it 'should generate a post request' do
          stub_request(:post, /#{BitPay::TEST_API_URI}.*/).to_return(:body => '{"awesome": "json"}')
          bitpay_client.send_request("POST", "whatever", facade: "merchant")
          expect(WebMock).to have_requested(:post, "#{BitPay::TEST_API_URI}/whatever")
        end
    end

  end

  describe "#pair_pos_client" do
    it 'throws a BitPayError with the error message if the token setting fails' do
      stub_const('ENV', {'BITPAY_PEM' => PEM})
      stub_request(:any, /#{BitPay::TEST_API_URI}.*/).to_return(status: 500, body: "{\n  \"error\": \"Unable to create token\"\n}")
      expect { bitpay_client.pair_pos_client(:claim_code) }.to raise_error(BitPay::BitPayError, '500: Unable to create token')
    end 

    it 'gracefully handles 4xx errors' do
      stub_const('ENV', {'BITPAY_PEM' => PEM})
      stub_request(:any, /#{BitPay::TEST_API_URI}.*/).to_return(status: 403, body: "{\n  \"error\": \"this is a 403 error\"\n}")
      expect { bitpay_client.pair_pos_client(:claim_code) }.to raise_error(BitPay::BitPayError, '403: this is a 403 error')
    end
  end

  describe "#create_invoice" do
    subject { bitpay_client }
    before {stub_const('ENV', {'BITPAY_PEM' => PEM})}
    it { is_expected.to respond_to(:create_invoice) }

    it 'should make call to the server to create an invoice' do
      stub_request(:post, /#{BitPay::TEST_API_URI}\/invoices.*/).to_return(:body => '{"data": "awesome"}')
      bitpay_client.create_invoice(id: "addd", price: 20, currency: "USD")
      assert_requested :post, "#{BitPay::TEST_API_URI}/invoices"
    end

    it 'should pass through the API error message from load_tokens' do
      stub_request(:get, /#{BitPay::TEST_API_URI}\/tokens.*/).to_return(status: 500, body: '{"error": "load_tokens_error"}')
      expect { bitpay_client.create_invoice(id: "addd", price: 20, currency: "USD") }.to raise_error(BitPay::BitPayError, '500: load_tokens_error')         
    end
  end
end


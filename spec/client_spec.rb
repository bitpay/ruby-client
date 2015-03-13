require 'spec_helper'

def tokens
    {"data" => 
      [{"merchant" => "MERCHANT_TOKEN"},
      {"pos" =>"POS_TOKEN"},
      {"merchant/invoice" => "9kv7gGqZLoQ2fxbKEgfgndLoxwjp5na6VtGSH3sN7buX"}
      ]
    }
end

describe BitPay::SDK::Client do
  let(:bitpay_client) { BitPay::SDK::Client.new({api_uri: BitPay::TEST_API_URI}) }
  let(:claim_code) { "a12bc3d" }

  before do
      # Stub JSON responses from fixtures
      stub_request(:get, /#{BitPay::TEST_API_URI}\/tokens.*/)
        .to_return(:status => 200, :body => tokens.to_json, :headers => {})
      stub_request(:get, "#{BitPay::TEST_API_URI}/invoices/TEST_INVOICE_ID?token=MERCHANT_TOKEN").
        to_return(:body => get_fixture('invoices_{id}-GET.json'))
      stub_request(:get, "#{BitPay::TEST_API_URI}/invoices/TEST_INVOICE_ID/refunds?token=MERCHANT_INVOICE_TOKEN").
        to_return(:body => get_fixture('invoices_{id}_refunds-GET.json'))
      stub_request(:get, "#{BitPay::TEST_API_URI}/invoices/TEST_INVOICE_ID/refunds/TEST_REQUEST_ID?token=MERCHANT_INVOICE_TOKEN").
        to_return(:body => get_fixture('invoices_{id}_refunds-GET.json'))
      stub_request(:post, "#{BitPay::TEST_API_URI}/invoices/TEST_INVOICE_ID/refunds").
        to_return(:body => get_fixture('invoices_{id}_refunds-POST.json'))
      stub_request(:post, "#{BitPay::TEST_API_URI}/nuttin").
        to_return(:body => get_fixture('response-nodata.json'))
      stub_request(:get, "#{BitPay::TEST_API_URI}/nuttin").
        to_return(:body => get_fixture('response-nodata.json'))
      stub_request(:delete, "#{BitPay::TEST_API_URI}/nuttin").
        to_return(:body => get_fixture('response-nodata.json'))
  end

  describe "#initialize" do

    it 'should be able to get pem file from the env' do
      stub_const('ENV', {'BITPAY_PEM' => PEM})
      expect {bitpay_client}.to_not raise_error
    end
    
  end

  describe "requests to endpoint without data field" do
    it "should return the json body" do
      expect(bitpay_client.post(path: "nuttin", params: {})["facile"]).to eq("is easy")
      expect(bitpay_client.get(path: "nuttin")["facile"]).to eq("is easy")
      expect(bitpay_client.delete(path: "nuttin")["facile"]).to eq( "is easy")
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
        expect(WebMock).to have_requested(:get, "#{BitPay::TEST_API_URI}/whatever?token=MERCHANT_TOKEN") 
      end
      
      it 'should handle query parameters gracefully' do
        stub_request(:get, /#{BitPay::TEST_API_URI}\/ledgers.*/).to_return(:body => '{"awesome": "json"}')
        bitpay_client.send_request("GET", "ledgers/BTC?startDate=2015-01-01&endDate=2015-02-01", facade: "merchant")
        expect(WebMock).to have_requested(:get, "#{BitPay::TEST_API_URI}/ledgers/BTC?startDate=2015-01-01&endDate=2015-02-01&token=MERCHANT_TOKEN")
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
    before do
      stub_const('ENV', {'BITPAY_PEM' => PEM})
    end

    it 'throws a BitPayError with the error message if the token setting fails' do
      stub_request(:any, /#{BitPay::TEST_API_URI}.*/).to_return(status: 500, body: "{\n  \"error\": \"Unable to create token\"\n}")
      expect { bitpay_client.pair_pos_client(claim_code) }.to raise_error(BitPay::BitPayError, '500: Unable to create token')
    end 

    it 'gracefully handles 4xx errors' do
      stub_request(:any, /#{BitPay::TEST_API_URI}.*/).to_return(status: 403, body: "{\n  \"error\": \"this is a 403 error\"\n}")
      expect { bitpay_client.pair_pos_client(claim_code) }.to raise_error(BitPay::BitPayError, '403: this is a 403 error')
    end

    it 'short circuits on invalid pairing codes' do
      100.times do
        claim_code = an_illegal_claim_code
        expect { bitpay_client.pair_pos_client(claim_code) }.to raise_error BitPay::ArgumentError, "pairing code is not legal"
      end
    end
  end

  describe "#create_invoice" do
    subject { bitpay_client }
    before {stub_const('ENV', {'BITPAY_PEM' => PEM})}
    it { is_expected.to respond_to(:create_invoice) }

    describe "should make the call to the server to create an invoice" do
      it 'allows numeric input for the price' do
        stub_request(:post, /#{BitPay::TEST_API_URI}\/invoices.*/).to_return(:body => '{"data": "awesome"}')
        bitpay_client.create_invoice(price: 20.00, currency: "USD")
        assert_requested :post, "#{BitPay::TEST_API_URI}/invoices"
      end

      it 'allows string input for the price' do
        stub_request(:post, /#{BitPay::TEST_API_URI}\/invoices.*/).to_return(:body => '{"data": "awesome"}')
        bitpay_client.create_invoice(price: "20.00", currency: "USD")
        assert_requested :post, "#{BitPay::TEST_API_URI}/invoices"
      end
    end

    it 'should pass through the API error message from load_tokens' do
      stub_request(:get, /#{BitPay::TEST_API_URI}\/tokens.*/).to_return(status: 500, body: '{"error": "load_tokens_error"}')
      expect { bitpay_client.create_invoice(price: 20, currency: "USD") }.to raise_error(BitPay::BitPayError, '500: load_tokens_error')         
    end

    it 'verifies the validity of the price argument' do
      expect { bitpay_client.create_invoice(price: "3,999", currency: "USD") }.to raise_error(BitPay::ArgumentError, 'Illegal Argument: Price must be formatted as a float')
    end
    
    it 'verifies the validity of the currency argument' do
      expect { bitpay_client.create_invoice(price: "3999", currency: "UASD") }.to raise_error(BitPay::ArgumentError, 'Illegal Argument: Currency is invalid.')
    end
  end

  describe '#refund_invoice' do
    subject { bitpay_client }
    before { stub_const('ENV', {'BITPAY_PEM' => PEM}) }
    it { is_expected.to respond_to(:refund_invoice) }
    
    it 'should get the token for the invoice' do
      bitpay_client.refund_invoice(id: 'TEST_INVOICE_ID')
      expect(WebMock).to have_requested :get, "#{BitPay::TEST_API_URI}/invoices/TEST_INVOICE_ID?token=MERCHANT_TOKEN"
    end
    
    it 'should generate a POST to the invoices/refund endpoint' do
      bitpay_client.refund_invoice(id: 'TEST_INVOICE_ID')
      expect(WebMock).to have_requested :post, "#{BitPay::TEST_API_URI}/invoices/TEST_INVOICE_ID/refunds"
    end
  end
  
  describe '#get_all_refunds_for_invoice' do
    subject { bitpay_client }
    before {stub_const('ENV', {'BITPAY_PEM' => PEM})}
    it { is_expected.to respond_to(:get_all_refunds_for_invoice) }  
    
    it 'should get the token for the invoice' do
      bitpay_client.get_all_refunds_for_invoice(id: 'TEST_INVOICE_ID')
      expect(WebMock).to have_requested :get, "#{BitPay::TEST_API_URI}/invoices/TEST_INVOICE_ID?token=MERCHANT_TOKEN"
    end
    it 'should GET all refunds' do
      bitpay_client.get_all_refunds_for_invoice(id: 'TEST_INVOICE_ID')
      expect(WebMock).to have_requested :get, "#{BitPay::TEST_API_URI}/invoices/TEST_INVOICE_ID/refunds?token=MERCHANT_INVOICE_TOKEN"
    end
  end
    
  describe '#get_refund' do
    subject { bitpay_client }
    before {stub_const('ENV', {'BITPAY_PEM' => PEM})}
    it { is_expected.to respond_to(:get_refund) }  
    it 'should get the token for the invoice' do
      bitpay_client.get_refund(invoice_id: 'TEST_INVOICE_ID', request_id: 'TEST_REQUEST_ID')
      expect(WebMock).to have_requested :get, "#{BitPay::TEST_API_URI}/invoices/TEST_INVOICE_ID?token=MERCHANT_TOKEN"
    end        
    it 'should GET a single refund' do
      bitpay_client.get_refund(invoice_id: 'TEST_INVOICE_ID', request_id: 'TEST_REQUEST_ID')
      expect(WebMock).to have_requested :get, "#{BitPay::TEST_API_URI}/invoices/TEST_INVOICE_ID/refunds/TEST_REQUEST_ID?token=MERCHANT_INVOICE_TOKEN"
    end
  end

  describe "#verify_tokens" do
    subject { bitpay_client }
    before {stub_const('ENV', {'BITPAY_PEM' => PEM})}
    it { is_expected.to respond_to(:verify_tokens) }
  end
end


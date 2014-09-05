require 'spec_helper'
ENV["privkey"] = "16d7c3508ec59773e71ae728d29f41fcf5d1f380c379b99d68fa9f552ce3ebc3"
ENV["pubkey"] = "0353a036fb495c5846f26a3727a28198da8336ae4f5aaa09e24c14a4126b5d969d"
ENV['SIN'] = "TfFVQhy2hQvchv4VVG4c7j4XPa2viJ9HrR8"

# def tokens
#     {"data": 
#       [{"merchant": "UraKc61hkJEj9A5yvTzUTa"},
#       {"pos":"AQFEbQkdfEUep14sp92TaG"},
#       {"merchant/invoice": "9kv7gGqZLoQ2fxbKEgfgndLoxwjp5na6VtGSH3sN7buX"}
#       ]
#     }
# end

describe BitPay::Client do
  let(:bitpay_client) { BitPay::Client.new }
  describe "#send_request" do
    before do
        allow(KeyUtils).to receive(:nonce).and_return('1')
        stub_request(:get, /.*test.*/).to_return(:status => 200, :body => '{"data": [{"merchant": "MERCHANTTOKEN"},{"pos":"POSTOKEN"},{"merchant/invoice": "9kv7gGqZLoQ2fxbKEgfgndLoxwjp5na6VtGSH3sN7buX"}]}', :headers => {})
        stub_request(:post, /.*test*/).to_return(:body => '{"awesome": "json"}')
    end
    context "GET" do    
      it 'should generate a get request' do
        bitpay_client.send_request("GET", "whatever", "merchant")
        expect(WebMock).to have_requested(:get, "https://test.bitpay.com/whatever?nonce=1&token=MERCHANTTOKEN") 
      end
      
    end
    context "POST" do
          it 'should generate a post request' do
            bitpay_client.send_request("POST", "whatever", "merchant")
            expect(WebMock).to have_requested(:post, "https://test.bitpay.com/whatever")
           end
      end
  end
end

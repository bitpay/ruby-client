require_relative '../spec_helper.rb'

describe "Live Integration Testing", type: :feature  do
  let(:bitpay_client) { BitPay::Client.new({api_uri: BitPay::TEST_API_URI}) }

  ## These are live tests against https://test.bitpay.com
  #  It is assumed that the provided private key is already associated with
  #  an account which can create invoices
  #

  before do
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
  


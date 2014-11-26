require_relative '../spec_helper.rb'

describe "create an invoice", javascript: true, type: :feature do
  before :all do
    WebMock.allow_net_connect!
    get_claim_code = -> {
      visit ROOT_ADDRESS
      click_link('Login')
      fill_in 'email', :with => TEST_USER
      fill_in 'password', :with => TEST_PASS
      click_button('loginButton')
      click_link "My Account"
      click_link "API Tokens", match: :first
      find(".token-access-new-button").find(".btn").click
      sleep 0.25
      click_button("Add Token")
      find(".token-claimcode", match: :first).text
    }
    set_client = -> {
      client = BitPay::Client.new(api_uri: ROOT_ADDRESS, pem: PEM, insecure: true)
      client.pair_pos_client(get_claim_code.call)
      client
    }
    @client ||= set_client.call
    @invoice_id ||= SecureRandom.uuid
    @price ||= (100..150).to_a.sample
    @invoice = @client.create_invoice(id: @invoice_id, currency: "USD", price: @price)
  end

  it "should create an invoice" do
    expect(@invoice["status"]).to eq "new"
  end

  it "should be able to retrieve an invoice" do
    expect(@client.get_public_invoice(id: @invoice['id'])["price"]).to eq @price
  end
end


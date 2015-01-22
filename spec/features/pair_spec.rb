require_relative '../spec_helper.rb'

describe "pairing a token", javascript: true, type: :feature do
  let(:claimCode) do 
    visit ROOT_ADDRESS
    click_link('Login')
    fill_in 'email', :with => TEST_USER
    fill_in 'password', :with => TEST_PASS
    click_button('loginButton')
    click_link "My Account"
    click_link "API Tokens", match: :first
    find(".token-access-new-button").find(".btn").find(".icon-plus").click
    find_button("Add Token", match: :first).click
    find(".token-claimcode", match: :first).text
  end
  let(:pem) { BitPay::KeyUtils.generate_pem }
  let(:client) { BitPay::SDK::Client.new(api_uri: ROOT_ADDRESS, pem: pem, insecure: true) }

  context "pairing an unpaired client" do
    it "should have no tokens before pairing" do
      expect(client.instance_variable_get(:@tokens)).to be_empty
    end
    it "should have a pos token after pairing" do
      sleep 1 # rate limit compliance
      response = client.pair_client({pairingCode: claimCode})  
      expect( response["data"].first["facade"] ).to eq("pos")
    end
    it "should fetch a client-initiated pairing code" do
      sleep 1 # rate limit compliance
      response = client.pair_client({})
      expect( response["data"].first["pairingCode"] ).not_to be_empty
    end
  end

end

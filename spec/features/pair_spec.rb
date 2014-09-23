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
    find(".token-access-new-button").find(".btn").click
    find(".token-claimcode", match: :first).text
  end
  let(:private_key) { BitPay::KeyUtils.generate_private_key }

  context "pairing an unpaired client" do
    let(:client) { BitPay::Client.new(api_uri: ROOT_ADDRESS, priv_key: private_key, insecure: true) }
    it "should have no tokens before pairing" do
      expect(client.instance_variable_get(:@tokens)).to be_empty
    end
    it "should have tokens after pairing" do
      client.pair_pos_client(claimCode)  
      client = BitPay::Client.new(api_uri: ROOT_ADDRESS, priv_key: private_key, insecure: true)
      expect(client.instance_variable_get(:@tokens)).not_to be_empty
    end
  end

end

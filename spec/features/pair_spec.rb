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
    sleep 0.25
    click_button("Add Token")
    find(".token-claimcode", match: :first).text
  end
  let(:pem) { BitPay::KeyUtils.generate_pem }
  let(:client) { BitPay::Client.new(api_uri: ROOT_ADDRESS, pem: pem, insecure: true) }

  context "pairing an unpaired client" do
    it "should have no tokens before pairing" do
      expect(client.instance_variable_get(:@tokens)).to be_empty
    end
    it "should have a pos token after pairing" do
      client.pair_pos_client(claimCode)  
      expect(client.instance_variable_get(:@tokens)['pos']).not_to be_empty
    end
  end

end

require 'spec_helper'

context 'local variables' do
  it "should find the root address" do
    expect(ROOT_ADDRESS).not_to be_nil
  end
  it "should find the user" do
    expect(TEST_USER).not_to be_nil
  end
  it "should find the user" do
    expect(TEST_PASS).not_to be_nil
  end
end

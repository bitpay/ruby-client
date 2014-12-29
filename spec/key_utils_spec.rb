require 'spec_helper'

describe BitPay::KeyUtils do
  let(:key_utils) {BitPay::KeyUtils}


  describe '.get_local_private_key' do
    it "should get the key from the ENV['PRIV_KEY'] variable" do
      stub_const('ENV', {'BITPAY_PEM' => PEM})
      expect(key_utils.get_local_pem_file).to eq(PEM)
    end
    
    it "should throw an error if the ENV['PRIV_KEY'] variable is not set" do
      expect {key_utils.get_local_pem_file}.to raise_error( BitPay::BitPayError )
    end

  end

  describe '.generate_pem' do
    it 'should generate a pem string' do
      regex = /BEGIN\ EC\ PRIVATE\ KEY/
      expect(regex.match(key_utils.generate_pem)).to be_truthy
    end
  end
  
  describe '.get_public_key_from_pem' do
    it 'should generate the right public key' do
      expect(key_utils.get_public_key_from_pem(PEM)).to eq(PUB_KEY)
    end
    
    it 'should get pem from the env if none is passed' do
      expect(key_utils.get_public_key_from_pem(PEM)).to eq(PUB_KEY)
    end

  end

  describe '.generate_sin_from_pem' do
    let(:pem){PEM}
    let(:sin){CLIENT_ID}

    it 'will return the right sin for the right pem' do
      expect(key_utils.generate_sin_from_pem(pem)).to eq sin
    end

    it 'will attempt to use an env variable if no key is provided' do
      stub_const('ENV', {'BITPAY_PEM' => PEM})
      expect(key_utils.generate_sin_from_pem(nil)).to eq sin
    end

  end

  context "errors when priv_key is not provided" do
    it 'will not retrieve public key' do 
      expect{key_utils.get_public_key_from_pem(nil)}.to raise_error(BitPay::BitPayError) 
    end

  end 
  
end

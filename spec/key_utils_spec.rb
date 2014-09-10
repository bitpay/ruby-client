require 'spec_helper'

describe BitPay::KeyUtils do
  let(:key_utils) {BitPay::KeyUtils}

  describe '.generate_private_key' do
    it 'should return a 256-bit number' do
      expect(key_utils.generate_private_key.to_s(2).length).to be <= 256
    end
  end

  describe '.get_local_private_key' do
    it "should get the key from the ENV['PRIV_KEY'] variable" do
      stub_const('ENV', {'PRIV_KEY' => PRIV_KEY})
      expect(key_utils.get_local_private_key).to eq(PRIV_KEY)
    end
    
    it 'should get the key from ~/.bitpay/api.key if env variable is not set'
    it 'should throw an exception if no local key can be found' do
      expect{key_utils.get_local_private_key}.to raise_error(BitPay::BitPayError)
    end
  end

  describe '.get_public_key' do
    it 'should generate the right public key' do
      expect(key_utils.get_public_key(PRIV_KEY)).to eq(PUB_KEY)
    end
    
    it 'should get priv_key from the env if none is passed' do
      stub_const('ENV', {'PRIV_KEY' => PRIV_KEY})
      expect(key_utils.get_public_key).to eq(PUB_KEY)
    end
      
    it 'should throw an error if no priv_key is provided' do
      expect {key_utils.get_public_key}.to raise_error(BitPay::BitPayError)
    end
    
  end

  describe '.get_sin' do
    
    it 'should generate a proper SIN' do
      expect(key_utils.get_sin(PRIV_KEY)).to eq(SIN)
    end
    
    it 'should get priv_key from the env if none is passed' do
      stub_const('ENV', {'PRIV_KEY' => PRIV_KEY})
      expect(key_utils.get_sin).to eq(SIN)
    end
    
    it 'should throw an error if no priv_key is provided' do
      expect{key_utils.get_sin}.to raise_error(BitPay::BitPayError)
    end

  end
  
  describe '.sign' do
    it 'should generate a valid signature'
  end
  
end

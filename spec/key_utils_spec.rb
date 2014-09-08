require 'spec_helper'

describe BitPay::KeyUtils do
  let(:key_utils) {BitPay::KeyUtils}

  describe '.generate_private_key' do
    it 'should return a valid private key'
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

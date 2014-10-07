require 'spec_helper'

describe BitPay::KeyUtils do
  let(:key_utils) {BitPay::KeyUtils}

  describe '.generate_private_key' do
    it 'should return a 256-bit number' do
      expect(key_utils.generate_private_key.to_i(16).to_s(2).length).to be <= 256
    end
  end

  describe '.get_local_private_key' do
    it "should get the key from the ENV['PRIV_KEY'] variable" do
      stub_const('ENV', {'BITPAY_PEM' => PEM})
      expect(key_utils.get_local_pem_file).to eq(PEM)
    end
    
    it 'should get the key from ~/.bitpay/bitpay.pem if env variable is not set' do
      allow(File).to receive(:read).with(BitPay::PRIVATE_KEY_PATH) {PEM}
      expect(key_utils.get_local_pem_file).to eq(PEM)
    end

  end

  describe '.generate_pem' do
    it 'should write a new key to ~/.bitpay/bitpay.pem' do
      file = class_double("File").as_stubbed_const
      double = double("Object").as_null_object
      allow(file).to receive(:path).with(BitPay::BITPAY_CREDENTIALS_DIR).and_return(double)
      expect(file).to receive(:open).with(BitPay::PRIVATE_KEY_PATH, 'w')
      key_utils.generate_pem
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
    let(:sin){"TeyN4LPrXiG5t2yuSamKqP3ynVk3F52iHrX"}

    it 'will return the right sin for the right pem' do
      expect(key_utils.generate_sin_from_pem(pem)).to eq sin
    end
  end

  context "errors when priv_key is not provided" do
    before :each do
      allow(File).to receive(:read).with(BitPay::PRIVATE_KEY_PATH) {nil}
    end

    it 'will not retrieve public key' do 
      expect{key_utils.get_public_key_from_pem(nil)}.to raise_error(BitPay::BitPayError) 
    end

  end 
  
end

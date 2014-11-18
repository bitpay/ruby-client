require 'spec_helper'

describe BitPay::KeyUtils do
  let(:key_utils) {BitPay::KeyUtils}


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
      fileutils = class_double("FileUtils").as_stubbed_const
      allow(fileutils).to receive(:mkdir_p).with(BitPay::BITPAY_CREDENTIALS_DIR).and_return(nil)
      expect(file).to receive(:open).with(BitPay::PRIVATE_KEY_PATH, 'w')
      key_utils.generate_pem
    end

  end
  
  describe '.retrieve_or_generate_pem' do
    it 'should write a new key to ~/.bitpay/bitpay.pem if there is no existing file' do
      file = class_double("File").as_stubbed_const
      fileutils = class_double("FileUtils").as_stubbed_const
      allow(file).to receive(:read).with(BitPay::PRIVATE_KEY_PATH).and_throw(StandardError)
      allow(fileutils).to receive(:mkdir_p).with(BitPay::BITPAY_CREDENTIALS_DIR).and_return(nil)
      expect(file).to receive(:open).with(BitPay::PRIVATE_KEY_PATH, 'w')
      key_utils.retrieve_or_generate_pem
    end

    it 'should retrieve the pem if there is an existing file' do
      file = class_double("File").as_stubbed_const
      fileutils = class_double("FileUtils").as_stubbed_const
      allow(fileutils).to receive(:mkdir_p).with(BitPay::BITPAY_CREDENTIALS_DIR).and_return(nil)
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
    let(:sin){CLIENT_ID}

    it 'will return the right sin for the right pem' do
      expect(key_utils.generate_sin_from_pem(pem)).to eq sin
    end

    it 'will retrieve the locally stored PEM if one is not provided' do
      allow(File).to receive(:read).with(BitPay::PRIVATE_KEY_PATH) {PEM}
      expect(key_utils.generate_sin_from_pem(nil)).to eq sin
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

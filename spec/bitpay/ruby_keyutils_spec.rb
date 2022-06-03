# frozen_string_literal: true

RSpec.describe Bitpay::RubyKeyutils do

  let(:key_utils) { Bitpay::RubyKeyutils }

  let(:pem) { ENV['PEM'] }

  let(:sin) { ENV['CLIENT_ID'] }

  it "has a version number" do
    expect(Bitpay::RubyKeyutils).not_to be nil
  end

  describe '.generate_pem' do
    before { @regex = /BEGIN\ EC\ PRIVATE\ KEY/ }

    it 'should generate a pem string' do
      expect(@regex.match(key_utils.generate_pem)).to be_truthy
    end
  end

  describe '.get_private_key_from_pem' do

    it 'should generate the right private key from pem' do
      expect(key_utils.get_private_key_from_pem(pem)).to eq(ENV['PRIV_KEY'])
    end

    it 'should raise error if the pem is not passed' do
      expect { key_utils.get_private_key_from_pem(nil) }
        .to raise_error(StandardError, 'Please specify a pem key')
    end

  end

  describe '.get_private_key' do

    before { @key = key_utils.create_key(pem) }

    it 'should generate the private key' do
      expect(key_utils.get_private_key(@key)).to eq(ENV['PRIV_KEY'])
    end

  end

  describe '.get_public_key_from_pem' do

    it 'should generate the right public key from pem' do
      expect(key_utils.get_public_key_from_pem(pem)).to eq(ENV['PUB_KEY'])
    end

    it 'should raise error if the pem is not passed' do
      expect { key_utils.get_public_key_from_pem(nil) }
        .to raise_error(StandardError, 'Please specify a pem key')
    end

  end

  describe '.get_public_key' do

    before { @key = key_utils.create_key(pem) }

    it 'should generate the public key' do
      expect(key_utils.get_public_key(@key)).to eq(ENV['PUB_KEY'])
    end

  end

  describe '.generate_sin_from_pem' do

    it 'will return the sin for the pem' do
      expect(key_utils.generate_sin_from_pem(pem)).to eq(sin)
    end

  end

  describe '.sign_with_pem' do

    before do
      message = "hello cincinnati"
      digest = Digest::SHA256.digest(message)

      signed_message = key_utils.sign_with_pem(pem, message)

      priv= OpenSSL::PKey::EC.new(pem).private_key.to_i
      group = ECDSA::Group::Secp256k1
      pk = group.generator.multiply_by_scalar(priv)
      decoded = ECDSA::Format::SignatureDerString.decode(signed_message.to_i(16).to_bn.to_s(2))
      @valid = ECDSA.valid_signature?(pk, digest, decoded)
    end

    it "should provide a valid signature" do
      expect(@valid).to be(true)
    end

  end

end

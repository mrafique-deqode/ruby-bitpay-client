require 'openssl'
require 'ecdsa'
require 'securerandom'
require 'digest/sha2'

module Bitpay

  class RubyKeyutils

    class << self

      # Generate the base64 encoded PEM key which contains both Public and Private key.
      def generate_pem
        key = OpenSSL::PKey::EC.new('secp256k1')
        key.generate_key
        key.to_pem
      end

      def create_key(pem)
        OpenSSL::PKey::EC.new(pem)
      end

      # Generate the Private key from the PEM key.
      def get_private_key_from_pem(pem)
        if pem
          key = create_key(pem)
          get_private_key(key)
        else
          raise StandardError, 'Please specify a pem key'
        end
      end

      def get_private_key(key)
        key.private_key.to_int.to_s(16)
      end

      # Generate the Public key from the PEM key.
      def get_public_key_from_pem(pem)
        if pem
          key = create_key(pem)
          get_public_key(key)
        else
          raise StandardError, 'Please specify a pem key'
        end
      end

      def get_public_key(key)
        key.public_key.group.point_conversion_form = :compressed
        key.public_key.to_bn.to_s(16).downcase
      end

      # Generates the System Identification Number from the Pem.
      def generate_sin_from_pem(pem)
        key = create_key(pem)
        key.public_key.group.point_conversion_form = :compressed
        public_key = key.public_key.to_bn.to_s(2)

        step_one = Digest::SHA256.hexdigest(public_key)
        step_two = Digest::RMD160.hexdigest([step_one].pack("H*"))
        step_three = '0F02' + step_two
        step_four_a = Digest::SHA256.hexdigest([step_three].pack("H*"))
        step_four = Digest::SHA256.hexdigest([step_four_a].pack("H*"))
        step_five = step_four[0..7]
        step_six = step_three + step_five
        encode_base58(step_six)
      end

      def sign_with_pem(pem, message)
        private_key = get_private_key_from_pem(pem)
        sign(message, private_key)
      end

      def sign(message, private_key)
        group = ECDSA::Group::Secp256k1
        digest = Digest::SHA256.digest(message)

        signature = nil
        while signature.nil?
          temp_key = 1 + SecureRandom.random_number(group.order - 1)
          signature = ECDSA.sign(group, private_key.to_i(16), digest, temp_key)
          return ECDSA::Format::SignatureDerString.encode(signature).unpack("H*").first
        end
      end

      private

      # Encodes the public key compressed with Base58 to return the SIN.
      def encode_base58 (data)
        code_string = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz'
        base = 58
        # Heaxdecimal representation of the data
        x = data.hex
        output_string = ''

        while x > 0 do
          remainder = x % base
          x = x / base
          output_string << code_string[remainder]
        end

        pos = 0
        while data[pos,2] == "00" do
          output_string << code_string[0]
          pos += 2
        end

        output_string.reverse()
      end

    end

  end

end
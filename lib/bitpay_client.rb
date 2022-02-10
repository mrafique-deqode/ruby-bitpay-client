# frozen_string_literal: true
# require 'pry'
libdir = File.dirname(__FILE__)
# binding.pry
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'dotenv/load'
require 'bitpay/client'
require 'bitpay/ruby_keyutils'
require 'bitpay/version'

module Bitpay

  module Client

    class << self

      def cert_file_path
        File.join File.dirname(__FILE__), 'bitpay','cacert.pem'
      end

      # User agent reported to API
      def user_agent
        'BitPay_Ruby_Client_v' + VERSION
      end

    end

    class Bitpay::ResponseError < StandardError; end

    class Bitpay::ArgumentError < ArgumentError; end

  end

end


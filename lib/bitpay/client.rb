require 'net/http'
require 'json'
require 'bitpay/rest_connector'
Dir["./lib/bitpay/exceptions/*.rb"].each {|file| require file }
Dir["./lib/bitpay/models/*/*.rb"].each {|file| require file }

module Bitpay

  class RubyClient

    include Bitpay::RestConnector
    include Bitpay::Models::Invoice

    # Create a Bitpay client with a pem file.
    #
    # * It uses the ruby-bitpay-keyutils to generate the required keys.
    # @note 'api_uri' should be passed in test environment, if not passed defaults to production.
    #
    # @return [Object<Bitpay::RubyClient>]
    def initialize(options={})
      @pem = options[:pem] || Bitpay::RubyKeyutils.generate_pem
      @key = Bitpay::RubyKeyutils.create_key(@pem)
      @priv_key = Bitpay::RubyKeyutils.get_private_key(@key)
      @pub_key = Bitpay::RubyKeyutils.get_public_key(@key)
      @client_id = Bitpay::RubyKeyutils.generate_sin_from_pem(@pem)
      @uri = URI.parse options[:api_uri] || 'https://test.bitpay.com'
      @user_agent = options[:user_agent] || 'BitPay_Ruby_Client_v0.1.0'
      @tokens = options[:tokens] || {}

      @https = Net::HTTP.new(@uri.host, @uri.port)
      @https.use_ssl = true
      @https.open_timeout = 10
      @https.read_timeout = 10

      # @todo Add the certificates
      @https.ca_file = "./cacert.pem"

      # Option to disable certificate validation in extraordinary circumstance.
      @https.verify_mode = if options[:insecure] == true
        OpenSSL::SSL::VERIFY_NONE
      else
        OpenSSL::SSL::VERIFY_PEER
      end

      # Option to enable http request debugging
      @https.set_debug_output($stdout) if options[:debug] == true
    end

    # Returns the unique Client ID for the client object.
    #
    # @return [String]
    def client_id
      @client_id
    end

    # Returns the unique Client ID for the client object.
    #
    # @return [String]
    def pem
      @pem
    end

    # Authenticate with Bitpay to set a valid token(created from a key) with account to get access
    # from the client side or the server side.
    #
    # @params params [Hash]
    #
    # @see BitPay authentication in 'https://github.com/bitpay/ruby-bitpay-client' README.md
    def pair_client(params = {})
      post(path: '/tokens', params: params, sign_request: true)
    end

    # Authenticate with Bitpay from server side, with pairing code generated from account.
    #
    # @params pairing_code [String]
    #
    # @note Not used at present.
    def pair_pos_client(pairing_code)
      pair_client(pairingCode: pairing_code) if pairing_code_valid?(pairing_code)
    end

    # Updates the Client object with the authenticated tokens fetched from server.
    #
    # @return [void]
    def refresh_tokens
      response = get(path: '/tokens')
      client_token = {}
      @tokens = response['data'].inject({}) { |data, value| data.merge(value) }
    end

    # Fetches the rates for the given currency.
    #
    # @params base_currency [String] Currency code for which we need to find the rate.
    #
    # @return [Hash]
    def get_rates(base_currency)
      get(path: "/rates/#{base_currency}", public: true)
    end

    # Fetches the rates for the given currency with other counter currency.
    #
    # @params base_currency [String] Currency code for which we need to find the rate.
    # @params counter_currency [String] Currency code for which we need to find the rate 
    # with base currency.
    #
    # @return [Hash]
    def get_pair_rate(base_currency, counter_currency)
      get(path: "/rates/#{base_currency}/#{counter_currency}", public: true)
    end

    # Fetches the list of currencies supported by Bitpay.
    #
    # @return [Hash]
    def get_currencies
      get(path: '/currencies', public: true)
    end

    private

    # Verifies the Pairing Code is valid or not.
    #
    # @params pairing_code [String]
    #
    # @return [Boolean, Bitpay::ArgumentError]
    #
    # @todo - Provision to verify if the pairing code is valid with Bitpay server if generated
    # from account.
    def pairing_code_valid?(pairing_code)
      regex = /^[[:alnum:]]{7}$/
      return true unless regex.match(pairing_code).nil?

      raise ArgumentError, 'Pairing code is invalid'
    end

    # Returns the token for the given facade of the Bitpay client.
    #
    # @return [String]
    def get_token(facade)
      refresh_tokens[facade] || raise(ResponseError, "Not authorized for facade: #{facade}")
    end

    # Returns the query string to filter the invoice records.
    #
    # @param (see #get_invoice)
    def query_filter(params)
      return if params.empty?

      query = ''
      params.each do |key, value|
        query += "&#{key}=#{value}"
      end
      query
    end

  end

end

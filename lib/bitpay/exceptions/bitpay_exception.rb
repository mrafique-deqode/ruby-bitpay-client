module Bitpay

  module Exceptions

    class BitpayException < StandardError

      NAME = "BITPAY-GENERIC"
      MESSAGE = "Unexpected Bitpay Exception"
      API_CODE = "000000"
      CODE = '100'

      # Construct the Bitpay Exception
      # @params name [string]
      # @params message [string]
      # @params code [number]
      # @params api_code [string]
      def initialize(name: nil, message: nil, code: '100', api_code: '000000')
        @name = name || NAME
        @message = message || MESSAGE
        @api_code = api_code || API_CODE
        @code = code || CODE
        message = @name + ': ' + @message + ': ' + @api_code + ': ' + @code

        return super(message)
      end

    end

  end

end

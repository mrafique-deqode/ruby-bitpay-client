module Bitpay

  module Models

    module Invoice

      # Creates the Invoice.
      #
      # @params price [Float]
      # @params currency [String]
      # @params sign_request [Boolean] Include signature and identity in request
      # @params params [Hash]
      #   * facade - To create the invoice for the facade
      def create_invoice(price:, currency:, sign_request: true, params: {})
        if price_format_valid?(price, currency) && currency_valid?(currency)
          params.merge!({ price: price, currency: currency })
          token = get_token(params[:facade])
          invoice = post(path: '/invoices', token: token, sign_request: sign_request, params: params)
          invoice['data']
        end
      end
  
      # Fetches the invoice with a facade version using the Token and given invoiceID.
      #
      # @params id [String] Invoice ID
      # @params facade [String] Facade name to fetch the version invoice
      # @params params [Hash] Filter keywords which we need to filter the invoices
      #   * dateStart
      #   * dateEnd
      #   * status
      #   * orderId
      #   * limit
      #   * offset
      def get_invoice(id:, facade: 'pos', params: {})
        token = get_token(facade)
        invoice = get(path: "/invoices/#{id}", token: token, query_filter: query_filter(params))
        invoice["data"]
      end
  
      # Fetches the invoice with a public version on given invoiceID.
      #
      # @param id [String] Invoice ID
      def get_public_invoice(id:)
        invoice = get(path: "/invoices/#{id}", public: true)
        invoice["data"]
      end

      private

      # Verifies the invoice price is in required format.
      #
      # * If it is invalid, raises Bitpay::ArgumentError.
      def price_format_valid?(price, currency)
        float_regex = /^[[:digit:]]+(\.[[:digit:]]{2})?$/
        return true if price.is_a?(Numeric) ||
          !float_regex.match(price).nil? ||
          (currency == 'BTC' && btc_price_format_valid?(price))

        raise ArgumentError, 'Illegal Argument: Price must be formatted as a float'
      end

      # Verifies the regex for a BTC currency invoice price.
      def btc_price_format_valid?(price)
        regex = /^[[:digit:]]+(\.[[:digit:]]{1,6})?$/

        !regex.match(price).nil?
      end

      # Verifies the invoice currency is valid or not.
      #
      # * If it is invalid, raises Bitpay::ArgumentError.
      def currency_valid?(currency)
        regex = /^[[:upper:]]{3}$/
        return true if !regex.match(currency).nil?

        raise Bitpay::Exceptions::BitpayException.new(
          message: 'Error: Currency code must be a type of Model.Currency'
        )
      end

    end

  end

end

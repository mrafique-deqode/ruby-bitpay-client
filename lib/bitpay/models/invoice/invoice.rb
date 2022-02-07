module Bitpay
    module Models
        module Invoice
            def create_invoice(price:, currency:, facade: 'pos', params: {})
                if price_format_valid?(price, currency) && currency_valid?(currency)
                    params.merge!({ price: price, currency: currency })
                    token = get_token(facade)
                    invoice = simple_post(path: '/invoices', token: token, params: params)
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
            # puts 'Inner test passed'
        end
    end
end
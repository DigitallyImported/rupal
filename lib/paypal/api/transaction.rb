module PayPal
  class Transaction

    class << self
      def refund(transaction_id, refund_type = 'Full', opt = {})
        Request.new({
          :method => 'RefundTransaction',
          :transactionid => transaction_id
        }.merge(opt)).send_request
      end
    end

  end
end
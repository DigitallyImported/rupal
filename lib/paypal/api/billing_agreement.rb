module PayPal
  class BillingAgreement
    class << self
      
      def redirect_url(token)
        "https://www.#{ENV == 'production' ? '' : 'sandbox.'}paypal.com/cgi-bin/webscr?cmd=_express-checkout&token=#{token}"
      end
      
      def setup(description, return_url, cancel_url, opt = {})
        resp = Request.new({
          :method => 'SetExpressCheckout',
          :returnurl => return_url,
          :cancelurl => cancel_url,
          :billingtype => 'MerchantInitiatedBilling',
          :billingagreementdescription => description
        }.merge(opt)).send_request
      end
      
      def create(token)
        Request.new(
          :method => 'CreateBillingAgreement',
          :token => token
        ).send_request
      end
      
      def details(token)
        Request.new(:method => 'GetBillingAgreementCustomerDetails', :token => token).send_request
      end
      
      def update(reference_id, description = nil, opt = {})
        params = {
          :method => 'BillAgreementUpdate',
          :referenceid => reference_id,
        }.merge(opt)
        params[:description] = description unless description.nil?
        
        Request.new(params).send_request
      end
      
      def cancel(reference_id)
        self.update(reference_id, nil, :billingagreementstatus => 'Canceled')
      end
      
    end
  end
end
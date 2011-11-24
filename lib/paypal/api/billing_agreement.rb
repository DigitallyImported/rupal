module PayPal
  class BillingAgreement
    class << self
      
      def redirect_url(token)
        "https://www.#{ENV == 'production' ? '' : 'sandbox.'}paypal.com/cgi-bin/webscr?cmd=_customer-billing-agreement&token=#{token}"
      end
      
      def setup(description, return_url, cancel_url, opt = {})
        Request.new({
          :method => 'SetCustomerBillingAgreement',
          :returnurl => return_url,
          :cancelurl => cancel_url,
          :billingtype => 'MerchantInitiatedBilling',
          :billingagreementdescription => description
        }.merge(opt)).send
      end
      
      def create(token)
        Request.new(
          :method => 'CreateBillingAgreement',
          :token => token
        ).send
      end
      
      def details(token)
        Request.new(:method => 'GetBillingAgreementCustomerDetails', :token => token).send
      end
      
      def update(reference_id, description = nil, opt = {})
        params = {
          :method => 'BillAgreementUpdate',
          :referenceid => reference_id,
        }.merge(opt)
        params[:description] = description unless description.nil?
        Request.new(params).send
      end
      
      def cancel(reference_id)
        self.update(reference_id, nil, :billingagreementstatus => 'Canceled')
      end
      
    end
  end
end
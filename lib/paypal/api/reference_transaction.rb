module PayPal
  class ReferenceTransaction
    
    ActionSale = 'Sale'
    ActionAuth = 'Authorization'
    
    class << self
      
      def sale(reference_id, amount, first_name, last_name, opt = {})
        self.create(reference_id, ActionSale, {
          :amt => amount,
          :first_name => first_name,
          :last_name => last_name
        }.merge(opt))
      end
      
      def authorization(reference_id, amount, first_name, last_name, opt = {})
        self.create(reference_id, ActionAuth, {
          :amt => amount,
          :first_name => first_name,
          :last_name => last_name
        }.merge(opt))
      end
      
      def create(reference_id, payment_action, opt = {})
        Request.new({
          :method => 'DoReferenceTransaction',
          :referenceid => reference_id,
          :paymentaction => payment_action
        }.merge(opt)).send
      end
      
    end
  end
end
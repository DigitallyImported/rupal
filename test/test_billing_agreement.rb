require 'helper'

class TestBillingAgreement < Test::Unit::TestCase
  SandboxUrl = 'https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_customer-billing-agreement&token='
  ProductionUrl = 'https://www.paypal.com/cgi-bin/webscr?cmd=_customer-billing-agreement&token='
  
  def setup_billing_agreement
    PayPal::BillingAgreement.setup(
        "Testing PayPal Billing Agreements", 
        'http://example.com/paypal/return',
        'http://example.com/paypal/cancel'
    )
  end
  
  test 'setup' do
    response = setup_billing_agreement
    
    assert response.success?
    assert response.data.include?(:token)
  end
  
  test 'redirect_url' do
    assert_equal "#{SandboxUrl}TEST", PayPal::BillingAgreement.redirect_url('TEST')
    PayPal.send :remove_const, :ENV
    PayPal.const_set :ENV, 'production'
    assert_equal "#{ProductionUrl}TEST", PayPal::BillingAgreement.redirect_url('TEST')
  end
  
  test 'details' do
    response = setup_billing_agreement
    
    assert response.success?
    assert response.data.include?(:token)
    
    response = PayPal::BillingAgreement.details(response.data[:token])
    assert response.success?
  end
  
  test 'details requires valid token' do
    response = PayPal::BillingAgreement.details('not a valid token')
    assert response.failure?
  end
end
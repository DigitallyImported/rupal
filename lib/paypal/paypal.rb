module PayPal
  ENV         = (defined?(Rails) && Rails.env) || ENV['RACK_ENV'] || 'development'
  ROOT        = (defined?(Rails) && Rails.root) || ::File.expand_path('.')
  CONFIG_NAME = 'paypal.yml'
  LOG_PREFIX  = 'paypal'
  
  autoload :BillingAgreement,     'paypal/api/billing_agreement'
  autoload :ReferenceTransaction, 'paypal/api/reference_transaction'
end

$:.unshift(File.dirname(__FILE__))
%w[ errors version constants config log request response ].each do |file|
  require "paypal/#{file}"
end
rupal
======

Ruby gem for interfacing PayPal NVP API

I don't have time for coming up with clever names. Ruby + PayPal == rupal, deal with it.

Changelog
---------
**v0.1.0**

- Added ReferenceTransaction API helper class
- Added BillingAgreement API helper class

**v0.0.1**

- Initial commit

Dependencies
----

- active_support for it's to\_query/to\_param methods
- retryable for, you guessed it, retrying failed connections/timeouts

Setup
-----

Create a configuration file 'paypal.yml' and place it in your apps config/ folder. The configuration file is automatically loaded for you and values are accessible via PayPal.config struct.

Example configuration:

	development: &dev
	  api:
	    url: https://api-3t.sandbox.paypal.com/nvp
	    version: 84.0
	    user: YOUR_PAYPAL_LOGIN@example.com
	    pwd: YOUR_API_PASSWORD
	    signature: YOUR_API_SIGNATURE
	  retries: 3

	production:
	  <<: *dev
	  api:
	    url: https://api-3t.paypal.com/nvp
		
Usage
----
	require 'rupal'
	
	response = PayPal::Request.new(:method => :DoCapture, ...).send
	if response.success?
	  puts "Request completed at #{response.timestamp}, CORRELATIONID=#{response.correlation_id}"
	  # do stuff with response.data hash
	else
	  response.errors.each { |e| puts e }
	end
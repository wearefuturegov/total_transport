Braintree::Configuration.environment = :sandbox
Braintree::Configuration.merchant_id = ENV['BRAINTREE_MERCHENT_ID']
Braintree::Configuration.public_key = ENV['BRAINTREE_PUBLIC_KEY']
Braintree::Configuration.private_key = ENV['BRAINTREE_PRIVATE_KEY']

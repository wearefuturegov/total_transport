FactoryGirl.define do
  factory(:passenger) do
    braintree_id nil
    braintree_token nil
    name "James Darling"
    phone_number "07811407085"
    verification_code "6579"
    verification_code_generated_at nil
  end
end

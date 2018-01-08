FactoryBot.define do
  factory(:passenger) do
    name "James Darling"
    phone_number "07811407085"
    verification_code "6579"
    verification_code_generated_at nil
    session_token { Digest::SHA1.hexdigest([Time.now, rand].join) }
  end
end

class PromoCode < ActiveRecord::Base
  before_create :create_code
  validates_presence_of :price_deduction

  def create_code
    self.code = SecretSanta.create_code
  end
end

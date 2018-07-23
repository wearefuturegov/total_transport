class PromoCode < ApplicationRecord
  before_create :create_code
  validates_presence_of :price_deduction

  has_one :booking
  
  def self.find_by_code(code)
    code = SecretSanta.normalize(code)
    where("code = ?", code).first
  end

  def used?
    !!booking
  end

  def available?
    !used?
  end
  
  private
  
    def create_code
      self.code = SecretSanta.create_code
    end
end

class Journey < ActiveRecord::Base
  belongs_to :route
  has_many :stops, through: :route
  has_many :bookings, dependent: :destroy
  belongs_to :vehicle
  belongs_to :supplier

  scope :available, -> {where('start_time > ?', Time.now)}

  def editable_by_supplier?(supplier)
    supplier.team == self.supplier.team
  end
end

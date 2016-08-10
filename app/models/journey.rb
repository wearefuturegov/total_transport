class Journey < ActiveRecord::Base
  belongs_to :route
  has_many :stops, through: :route
  has_many :bookings, dependent: :destroy
  belongs_to :vehicle
  belongs_to :supplier
  validates_presence_of :vehicle, :supplier, :start_time, :route

  scope :available, -> {where('start_time > ? AND open_to_bookings IS TRUE', Time.now)}

  def editable_by_supplier?(supplier)
    supplier.team == self.supplier.team
  end

  def is_booked?
    bookings.count > 0
  end
end

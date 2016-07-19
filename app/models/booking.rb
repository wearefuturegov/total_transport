class Booking < ActiveRecord::Base
  belongs_to :journey
  belongs_to :pickup_stop
  belongs_to :dropoff_stop
end

class Booking < ActiveRecord::Base
  belongs_to :journey
  belongs_to :pickup_stop, class_name: 'Stop'
  belongs_to :dropoff_stop, class_name: 'Stop'
end

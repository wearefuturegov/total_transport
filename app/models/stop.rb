class Stop < ActiveRecord::Base
  belongs_to :route
  acts_as_list scope: :route
end

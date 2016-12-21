class Landmark < ActiveRecord::Base
  belongs_to :stop
  def name
    if super.blank?
      "Unnamed Landmark"
    else
      super
    end
  end
end

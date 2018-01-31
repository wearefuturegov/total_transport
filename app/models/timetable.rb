class Timetable < ActiveRecord::Base
  belongs_to :route
  belongs_to :supplier

  has_many :timetable_times, dependent: :destroy
  has_many :journeys, through: :timetable_times
  
  after_create :create_journeys
  
  accepts_nested_attributes_for :timetable_times, reject_if: :all_blank, allow_destroy: true
  
  private
  
    def create_journeys
      (from..to).each do |date|
        next unless days.map(&:to_i).include?(date.wday)
        timetable_times.each do |t|
          time = t.time.strftime('%H:%M')
          start_time = DateTime.parse "#{date.to_s}T#{time}"
          t.create_journey(start_time).id
        end
      end
      save
    end
  
end

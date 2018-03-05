class Timetable < ActiveRecord::Base
  belongs_to :route
  belongs_to :team

  has_many :timetable_times, dependent: :destroy
  has_many :journeys, through: :timetable_times
  
  after_create :create_journeys
  
  accepts_nested_attributes_for :timetable_times, reject_if: :all_blank, allow_destroy: true
  
  def extend(extension_date)
    (to..extension_date).each { |date| create_journeys_for_date(date) }
    update_attribute(:to, extension_date)
  end
  
  private
  
    def create_journeys
      (from..to).each { |date| create_journeys_for_date(date) }
    end
    
    def create_journeys_for_date(date)
      return unless days.map(&:to_i).include?(date.wday)
      timetable_times.each do |t|
        time = t.time.strftime('%H:%M')
        start_time = DateTime.parse "#{date.to_s}T#{time}"
        t.create_journey(start_time).id
      end
    end
  
end

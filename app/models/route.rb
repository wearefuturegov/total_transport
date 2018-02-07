class Route < ActiveRecord::Base
  has_many :stops, -> { order(position: :asc) }, dependent: :destroy
  has_many :journeys, -> { order(start_time: :asc) }, dependent: :destroy
  has_many :suggested_journeys, dependent: :destroy
  has_many :places, through: :stops
  has_many :sub_routes, class_name: 'Route'
  belongs_to :route
  belongs_to :pricing_rule
  
  after_save :queue_geometry, :update_subroutes
  
  validate :check_sub_route
  
  scope :main_routes, -> { where(route_id: nil) }

  def self.bookable_routes
    all.reject {|route| route.stops.count <= 2}
  end
  
  def self.available_routes(start_place, destination_place)
    from = Stop.where(place: start_place)
    from_routes = from.map { |s| s.route }
    to = Stop.where(place: destination_place)
    to_routes = to.map { |s| s.route }
    (from_routes & to_routes)
  end
  
  def self.copy!(source_id, stops = nil)
    source = Route.find(source_id)
    stops ||= source.stops
    route = source.dup
    source.stops.each do |s|
      next unless stops.include?(s)
      route.stops << s.copy
    end
    route.route_id = source_id
    route.save
    route
  end

  def name
    if self[:name].nil?
      if stops.count > 1
        "Route #{self.id}: #{self.stops.first.name} - #{self.stops.last.name}"
      else
        "Route #{self.id}"
      end
    else
      self[:name]
    end
  end

  def forwards_name
    "#{stops.first.name} - #{stops.last.name}"
  end

  def backwards_name
    "#{stops.last.name} - #{stops.first.name}"
  end

  def has_available_journeys?
    journeys.available.any?
  end

  def available_journeys_by_date(reversed: false, from_time: Time.now)
    available_journeys_by_date = {}
    if reversed
      journeys_in_direction = journeys.backwards
    else
      journeys_in_direction = journeys.forwards
    end
    journeys_in_direction.available.where("start_time > ?", from_time).limit(20).each do |journey|
      available_journeys_by_date[journey.start_time.to_date] ||= []
      available_journeys_by_date[journey.start_time.to_date] << journey
    end
    available_journeys_by_date
  end
  
  def flipped_geometery
    geometry.map { |ll| [ll[1], ll[0]] } unless geometry.nil?
  end
  
  private
    
    def queue_geometry
      SetRouteGeometry.enqueue(id)
    end
    
    def update_subroutes
      sub_routes.update_all(name: name, pricing_rule_id: pricing_rule&.id)
    end
    
    def check_sub_route
      if !route.nil? && sub_routes.count > 0
        errors.add(:sub_routes, 'cannot be added for a sub route')
      end
    end
end

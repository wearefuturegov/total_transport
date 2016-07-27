class Supplier < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :team
  has_many :journeys
  before_create :set_team

  validates_presence_of :name, :phone_number

  def set_team
    if self.team.blank?
      self.team = Team.create!
    end
  end

  def solo_team?
    team.solo_team?
  end
end

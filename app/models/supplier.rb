class Supplier < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :team
  has_many :journeys, dependent: :destroy
  before_create :set_team
  after_destroy :destroy_team_if_solo
  after_update :send_approved_email?

  validates_presence_of :name, :phone_number

  def set_team
    if self.team.blank?
      self.team = Team.create!
    end
  end

  def solo_team?
    team.solo_team?
  end

  def active_for_authentication?
    super && approved?
  end

  def destroy_team_if_solo
    team.destroy if team.empty?
  end

  def inactive_message
    if !approved?
      :not_approved
    else
      super
    end
  end

  def send_approved_email?
    if approved_changed? && approved?
      send_approved_email!
    end
  end

  def send_approved_email!
    SupplierMailer.approved_email(self).deliver
  end
end

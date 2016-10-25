class Supplier < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :team
  has_many :journeys, dependent: :destroy
  has_many :supplier_suggestions, dependent: :destroy
  before_create :set_team
  after_destroy :destroy_team_if_solo
  after_update :send_approved_email?

  has_attached_file :photo, styles: {
    thumb: '100x100>',
    square: '200x200#',
    medium: '300x300>'
  }

  validates_attachment_content_type :photo, :content_type => /\Aimage\/.*\Z/
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
    team.destroy if team.empty_team?
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

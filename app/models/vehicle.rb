class Vehicle < ActiveRecord::Base
  belongs_to :team
  has_many :journeys, dependent: :destroy
  validates_presence_of :team, :seats, :registration
  has_and_belongs_to_many :generated_journeys

  has_attached_file :photo, styles: {
    thumb: '100x100>',
    square: '200x200#',
    medium: '300x300>'
  }

  validates_attachment_content_type :photo, :content_type => /\Aimage\/.*\Z/
end

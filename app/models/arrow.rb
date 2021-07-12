class Arrow < ApplicationRecord
  validates :description, presence: true
  validates :description, length: { minimum: 50, maximum: 280 }

  belongs_to :author, class_name: "User"
  belongs_to :owner, class_name: "User"
end

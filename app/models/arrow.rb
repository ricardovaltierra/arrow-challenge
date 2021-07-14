class Arrow < ApplicationRecord
  validates :description, presence: true
  validates :description, length: { minimum: 30, maximum: 280 }

  belongs_to :author, class_name: "User"
  belongs_to :owner, class_name: "User"

  scope :arrows_with_author, -> (current_user) { 
    current_user
    .owned_arrows
    .includes(:author)
    .order('created_at DESC')
  }
end

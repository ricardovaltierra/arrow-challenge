class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  has_many :authored_arrows, foreign_key: 'author_id',
                             class_name: 'Arrow',
                             dependent: :destroy
  has_many :owned_arrows, foreign_key: 'owner_id',
                          class_name: 'Arrow',
                          dependent: :destroy

  scope :to_select, -> (current_user) { 
    where('id != ?', current_user) 
  }
end

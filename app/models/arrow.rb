class Arrow < ApplicationRecord
  belongs_to :author, class_name: "User"
  belongs_to :owner, class_name: "User"
end

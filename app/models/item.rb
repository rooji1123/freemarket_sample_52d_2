class Item < ApplicationRecord
  has_many :comments, dependent: :destroy, dependent: :destroy
  has_many :item_images, dependent: :destroy, dependent: :destroy
  has_one :delivery, dependent: :destroy, dependent: :destroy
end

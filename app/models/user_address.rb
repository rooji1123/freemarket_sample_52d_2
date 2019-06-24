class UserAddress < ApplicationRecord
  belongs_to :user, inverse_of: :user_address

  validates :last_name_address, presence: true
  validates :first_name_address, presence: true
  validates :last_name_kana_address, presence: true
  validates :first_name_kana_address, presence: true
  validates :postal_code, presence: true
  validates :country_id, presence: true
  validates :city, presence: true
  validates :address, presence: true
  validates :building_name, presence: false
  validates :phone_number, presence: false
end
class UserInformation < ApplicationRecord
  belongs_to :user, inverse_of: :user_information

  validates :last_name, presence: true
  validates :first_name, presence: true
  validates :last_name_kana, presence: true
  validates :first_name_kana, presence: true
  validates :birth_year, presence: true
  validates :birth_month, presence: true
  validates :birth_day, presence: true
  validates :check_phone_number, presence: true, format: { with: /\A(070|080|090)\d{8}\Z/}
end

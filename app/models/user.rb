# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default("")
#  encrypted_password     :string           default("")
#  name                   :string
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  app_uuid               :string
#  last_post              :datetime
#  role                   :integer          default("0")
#  store_owner_code       :string
#
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :registerable

  with_options if: :admin? do |admin|
    admin.validates_presence_of :email
    admin.validates_presence_of :password, if: :password_required?
    admin.validates_confirmation_of :password, if: :password_required?
    admin.validates_length_of :password, within: 8..128, allow_blank: true
  end
  validates_uniqueness_of :email, unless: proc { |u| u.email.blank? }

  has_many :user_stores, inverse_of: :manager
  has_many :stores, through: :user_stores
  has_many :created_stores, class_name: 'Store', foreign_key: :created_by_id
  has_many :status_crowdsource_users

  has_secure_token :store_owner_code

  enum role: {user: 0, store_owner: 1, general_manager: 2, admin: 3, contributor: 4}

  def self.search(search)
    return all unless search

    where('users.name ilike ? OR email ilike ? OR app_uuid ilike ?',
          "%#{search}%", "%#{search}%",
          "%#{search}%")
  end

  def display_name
    name.presence || email.presence || "ID: #{id}"
  end

  protected

  # Checks whether a password is needed or not. For validations only.
  # Passwords are always required if it's a new record, or if the password
  # or confirmation are being set somewhere.
  def password_required?
    admin? && (!persisted? || !password.nil? || !password_confirmation.nil?)
  end
end

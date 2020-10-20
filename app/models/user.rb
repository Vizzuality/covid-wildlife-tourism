# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  name                   :string
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  role                   :integer          default("0")
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  phone                  :string
#  sign_in_count          :integer          default("0"), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :registerable,
         :confirmable, :trackable

  with_options if: :admin? do
    validates :email, presence: true
    validates :password, presence: true, if: :password_required?
    validates :password, confirmation: true, if: :password_required?
    validates :password, length: {within: 8..128, allow_blank: true}
  end
  validates :email, uniqueness: true, unless: proc { |u| u.email.blank? }
  validates :phone, uniqueness: true, unless: proc { |u| u.phone.blank? }

  has_many :user_stores, inverse_of: :manager
  has_many :stores, through: :user_stores
  has_many :created_stores, class_name: 'Store', foreign_key: :created_by_id, inverse_of: :created_by

  enum role: {user: 0, admin: 1}

  def self.search(search)
    return all unless search

    where('users.name ilike ? OR email ilike ? OR app_uuid ilike ?',
          "%#{search}%", "%#{search}%",
          "%#{search}%")
  end

  def display_name
    name.presence || email.presence || "ID: #{id}"
  end
  alias_method :text, :display_name

  protected

  # Checks whether a password is needed or not. For validations only.
  # Passwords are always required if it's a new record, or if the password
  # or confirmation are being set somewhere.
  def password_required?
    admin? && (!persisted? || !password.nil? || !password_confirmation.nil?)
  end
end

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
#  role                   :integer          default("user")
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  phone                  :string
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  organization           :string
#  position               :string
#  validated              :boolean          default(FALSE)
#
FactoryBot.define do
  factory :user do
    factory :admin_user, class: 'User' do
      role { 'admin' }
      password { 'testpassword' }
      sequence(:email) { |n| "#{n}@test.com" }
    end
  end
end

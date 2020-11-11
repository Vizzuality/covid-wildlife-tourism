# == Schema Information
#
# Table name: stores
#
#  id                :bigint           not null, primary key
#  name              :string
#  street            :string
#  city              :string
#  district          :string
#  country           :string
#  zip_code          :string
#  latitude          :float
#  longitude         :float
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  lonlat            :geometry         point, 0
#  state             :integer          default("waiting_approval")
#  created_by_id     :bigint
#  updated_by_id     :bigint
#  municipality      :string
#  search_name       :string
#  website           :string
#  type              :string           not null
#  population_size   :integer
#  user_is_owner     :boolean          default(FALSE), not null
#  owner_details     :text
#  farming_reliance  :integer
#  wildlife_reliance :integer
#  enterprise_type   :string           default([]), is an Array
#  ownership         :string
#  reason_to_change  :text
#  related_store_id  :bigint
#
FactoryBot.define do
  factory :store do
    name { 'MyString' }
    latitude { 1.5 }
    longitude { 1.5 }
    type { 'Community' }
  end
end

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
class Community < Store
  enum population_size: { '<50': 0, '51-100': 1, '101-200': 2, '201-500': 3, '501-1000': 4, '>1000': 5 }
  enum farming_reliance: { 'f_high': 0, 'f_medium': 1, 'f_low': 2, 'f_nil': 3 }
  enum wildlife_reliance: { 'w_high': 0, 'w_medium': 1, 'w_low': 2, 'w_nil': 3 }

  validates :enterprise_type, absence: true
  validates :ownership, absence: true
  validates :website, http_url: true
end

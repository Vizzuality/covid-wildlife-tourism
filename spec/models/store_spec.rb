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
require 'rails_helper'

describe Store do
  describe '#in_bounding_box' do
    it 'gets intersected store as geojson' do
      bbox = [[0, 0], [2, 2]]
      tesco = Store.create(name: 'Tesco', lonlat: 'POINT(1 1)')
      Store.create(name: 'Asda', lonlat: 'POINT(1,3)')

      query = Store.in_bounding_box(bbox)

      expect(query).to eq([tesco])
    end
  end
end

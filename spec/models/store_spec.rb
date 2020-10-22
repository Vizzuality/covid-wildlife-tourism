# == Schema Information
#
# Table name: stores
#
#  id                  :bigint           not null, primary key
#  name                :string
#  group               :string
#  street              :string
#  city                :string
#  district            :string
#  country             :string
#  zip_code            :string
#  latitude            :float
#  longitude           :float
#  capacity            :integer
#  details             :text
#  store_type          :integer          default("supermarket"), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  lonlat              :geometry         point, 0
#  state               :integer          default("waiting_approval")
#  reason_to_delete    :text
#  open                :boolean          default(TRUE)
#  created_by_id       :bigint
#  updated_by_id       :bigint
#  from_osm            :boolean          default(FALSE)
#  original_id         :bigint
#  source              :string
#  make_phone_calls    :boolean          default(FALSE)
#  phone_call_interval :integer          default(60)
#  municipality        :string
#  search_name         :string
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

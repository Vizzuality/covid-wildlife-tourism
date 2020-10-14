# == Schema Information
#
# Table name: stores
#
#  id               :bigint           not null, primary key
#  name             :string
#  group            :string
#  street           :string
#  city             :string
#  district         :string
#  country          :string
#  zip_code         :string
#  latitude         :float
#  longitude        :float
#  capacity         :integer
#  details          :text
#  store_type       :integer          default("1"), not null
#  url              :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  lonlat           :geometry         point, 0
#  state            :integer          default("1")
#  reason_to_delete :text
#  created_by_id    :bigint
#  updated_by_id    :bigint
#  source           :string
#  municipality     :string
#  search_name      :string
#
class Store < ApplicationRecord
  include UserTrackable
  include PgSearch::Model

  has_one_attached :photo

  RADIUS = 5000
  PROJECTION = 4326

  has_many :user_stores, inverse_of: :store, dependent: :destroy
  has_many :managers, through: :user_stores

  enum store_type: {supermarket: 1, pharmacy: 2, restaurant: 3,
                    gas_station: 4, bank: 5, coffee: 6, kiosk: 7,
                    other: 8, atm: 9, post_office: 10, beach: 11}
  enum state: {waiting_approval: 1, live: 2, marked_for_deletion: 3, archived: 4}

  validates :capacity, allow_nil: true, numericality: {greater_than: 0}

  scope :by_country, ->(country) { where(country: country) }
  scope :by_group, ->(group) { where(group: group) }
  scope :by_state, ->(state) { where(state: state) }
  scope :by_store_type, ->(store_type) { where(store_type: store_type) }
  scope :available, -> { where(state: [:live, :marked_for_deletion]).where(open: true) }

  after_save :set_lonlat
  before_save :update_search_name, if: :will_save_change_to_name?

  pg_search_scope :full_text_search,
                  against: {
                    name: 'A',
                    street: 'B',
                    district: 'C',
                    city: 'D'
                  },
                  using: {
                    tsearch: {
                      prefix: true
                    }
                  },
                  ignoring: :accents

  pg_search_scope :api_text_search,
                  against: [:search_name],
                  using: {
                    tsearch: {
                      prefix: true,
                      dictionary: 'english'
                    }
                  },
                  ignoring: :accents

  def address(unique: false)
    result = [street, city, country].map(&:presence).compact
    result << "#{I18n.t("activerecord.enums.store.store_types.#{store_type}")}-#{id}" if unique
    result.join(', ')
  end

  def text
    str = name
    str += " [#{group}]" if group
    str += ", #{street}" if street
    str += " ID: #{id}"
    str
  end

  def self.groups
    select(:group).order(:group).distinct.pluck(:group).map(&:presence).compact
  end

  def self.countries
    select(:country).order(:country).distinct.pluck(:country).map(&:presence).compact
  end

  def self.search(search)
    return all unless search

    where('name ilike ? OR street ilike ? OR district ilike ? OR city ilike ?',
          "%#{search}%", "%#{search}%",
          "%#{search}%", "%#{search}%")
  end

  def self.retrieve_stores(lat, lon)
    query = <<~SQL
      ST_CONTAINS(
        ST_BUFFER(
          ST_SetSRID(
            ST_MakePoint(#{lon}, #{lat}), 4326)::geography,
              #{RADIUS})::geometry, lonlat)
    SQL

    where(query).available
  end

  def self.retrieve_closest(lat, lon)
    query = <<~SQL
      DISTINCT
      stores.*,
      ST_SetSRID(ST_MakePoint(#{lon}, #{lat}),4326) <-> stores.lonlat AS distance
    SQL

    select(query).order('distance ASC')
  end

  def self.in_bounding_box(coordinates)
    Store.where(['lonlat && ST_MakeEnvelope(?, ?, ?, ?, 4326)',
                 coordinates.flatten(1)].flatten(1))
  end

  def self.to_csv
    CSV.generate(headers: true, force_quotes: true) do |csv|
      csv << %w(id name store_type latitude longitude street city district
                country source created_at created_by updated_at updated_by)
      all.find_each do |store|
        csv << [store.id, store.name, store.store_type, store.latitude, store.longitude,
                store.street, store.city, store.district, store.country, store.source,
                store.created_at.strftime('%d/%m/%Y %H:%M'), store.created_by&.display_name,
                store.updated_at.strftime('%d/%m/%Y %H:%M'), store.updated_by&.display_name]
      end
    end
  end

  def cache_key
    updated_at
  end

  private

  # x: longitude
  # y: latitude
  def set_lonlat
    return unless persisted? && latitude.present? && longitude.present?

    sql = <<~SQL
      UPDATE stores
      SET lonlat = ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)
      WHERE id = #{id}
    SQL
    ActiveRecord::Base.connection.execute sql
  end

  def update_search_name
    locale = 'en'

    prefix = I18n.t("activerecord.enums.store.store_types.#{store_type}", locale: locale)
    self.search_name = if name&.downcase&.include?(prefix.downcase)
                         name
                       else
                         [prefix, name].compact.join(' ')
                       end
  end
end

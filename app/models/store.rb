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
class Store < ApplicationRecord
  include UserTrackable
  include PgSearch::Model

  PROJECTION = 4326

  #self.abstract_class = true

  has_many :user_stores, inverse_of: :store, dependent: :destroy
  has_many :managers, through: :user_stores

  validates_presence_of :name

  enum state: {waiting_approval: 1, live: 2, marked_for_deletion: 3, archived: 4}

  scope :by_country, ->(country) { where(country: country) }
  scope :by_state, ->(state) { where(state: state) }
  scope :available, -> { where(state: [:live, :marked_for_deletion]) }

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

  def self.countries
    select(:country).order(:country).distinct.pluck(:country).map(&:presence).compact
  end

  def self.search(search)
    return all unless search

    where('name ilike ? OR street ilike ? OR district ilike ? OR city ilike ?',
          "%#{search}%", "%#{search}%",
          "%#{search}%", "%#{search}%")
  end

  def self.in_bounding_box(coordinates)
    Store.where(['lonlat && ST_MakeEnvelope(?, ?, ?, ?, 4326)',
                 coordinates.flatten(1)].flatten(1))
  end

  def self.to_csv
    CSV.generate(headers: true, force_quotes: true) do |csv|
      csv << %w(id name latitude longitude street city district
                country created_at created_by updated_at updated_by)
      all.find_each do |store|
        csv << [store.id, store.name, store.latitude, store.longitude,
                store.street, store.city, store.district, store.country,
                store.created_at.strftime('%d/%m/%Y %H:%M'), store.created_by&.display_name,
                store.updated_at.strftime('%d/%m/%Y %H:%M'), store.updated_by&.display_name]
      end
    end
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

    self.search_name = name
  end
end

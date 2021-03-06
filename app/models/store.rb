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
require 'csv'
class Store < ApplicationRecord
  include UserTrackable
  include PgSearch::Model

  PROJECTION = 4326

  has_many :user_stores, inverse_of: :store, dependent: :destroy
  has_many :managers, through: :user_stores

  validates_presence_of :name

  enum state: {live: 2, waiting_approval: 1, to_replace: 3}

  scope :by_country, ->(country) { where(country: country) }
  scope :by_state, ->(state) { where(state: state) }
  scope :by_type, ->(type) { where(type: type) }
  # scope :available, -> { where(state: [:live, :marked_for_deletion]) }
  scope :mine_or_live, ->(id) { where("(state = #{Store.states[:live]} or created_by_id = #{id})")}
  scope :live, -> { where(state: :live) }
  scope :with_location, -> { where.not(latitude: nil, longitude: nil) }
  scope :mine, ->(id) { where(created_by_id: id) }

  after_save :set_lonlat
  before_save :update_state
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
  def self.to_csv
    CSV.generate(headers: true, force_quotes: true) do |csv|
      csv << %w(id type state name latitude longitude
                website population_size owner_details farming_reliance
                wildlife_reliance enterprise_types ownership
                created_at created_by updated_at updated_by)
      all.find_each do |store|
        csv << [store.id, store.class.name, store.state, store.name, store.latitude, store.longitude,
                store.website, store.population_size, store.owner_details, store.farming_reliance,
                store.wildlife_reliance, store.enterprise_types, store.ownership,
                store.created_at.strftime('%d/%m/%Y %H:%M'), store.created_by&.display_name,
                store.updated_at.strftime('%d/%m/%Y %H:%M'), store.updated_by&.display_name]
      end
    end
  end

  def enterprise_types=(input_list)
    self.enterprise_type = input_list.split(',') rescue []
  end

  def enterprise_types
    enterprise_type.join(',') rescue ''
  end

  def self.types
    {'Community' => 'Community', 'Enterprise' => 'Enterprise'}
  end

  def approve
    if state.eql? 'waiting_approval'
      self.state = 'live'
      save
    elsif state.eql? 'to_replace'
      approve_replacement
    else
      errors.add(:state, t('views.admin.stores.pin_approved_unsuccessfully'))
      false
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

  private

  def update_state
    return if related_store_id.nil?

    self.state = 'to_replace'
  end

  def approve_replacement
    if related_store_id.blank?
      errors.add(:related_store_id, 'There is no related store to replace')
      return false
    end

    rs = Store.find(related_store_id)
    %i[name latitude longitude website population_size enterprise_type ownership].each do |attr|
      rs.write_attribute(attr, self[attr])
    end
    rs.updated_by_id = created_by_id

    Store.skip_callback(:save, :before, :set_updated_by)
    result = rs.save
    Store.set_callback(:save, :before, :set_updated_by)

    if result
      destroy
      true
    else
      self.errors = rs.errors
      false
    end
  end
end


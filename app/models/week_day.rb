# == Schema Information
#
# Table name: week_days
#
#  id           :bigint           not null, primary key
#  day          :integer          not null
#  opening_hour :time
#  closing_hour :time
#  active       :boolean          default("false")
#  timestamps   :string
#  store_id     :bigint
#
class WeekDay < ApplicationRecord
  belongs_to :store

  validates_uniqueness_of :day, scope: :store_id
  validate :time_order

  enum day: { sunday: 0, monday: 1, tuesday: 2, wednesday: 3, thursday: 4, friday: 5, saturday: 6 }

  private

  def time_order
    return if opening_hour.blank? && closing_hour.blank?
    return errors.add(:opening_hour, 'You must fill in both opening and closing hours') unless opening_hour.present? && closing_hour.present?

    errors.add(:opening_hour, 'You must open before you close') if opening_hour > closing_hour
  end
end

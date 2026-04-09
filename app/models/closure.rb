class Closure < ApplicationRecord
  validates :start_on, :end_on, presence: true
  validate :end_after_start

  scope :upcoming, -> { where("end_on >= ?", Date.current).order(:start_on) }
  scope :active_today, -> { where("start_on <= ? AND end_on >= ?", Date.current, Date.current) }

  def formatted_range
    if start_on == end_on
      I18n.l(start_on, format: :long)
    else
      "#{I18n.l(start_on, format: :long)} au #{I18n.l(end_on, format: :long)}"
    end
  end

  private

  def end_after_start
    return if start_on.blank? || end_on.blank?
    errors.add(:end_on, "doit être postérieure ou égale à la date de début") if end_on < start_on
  end
end

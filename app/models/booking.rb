class Booking < ApplicationRecord
  # enum
  enum booking_status: {pending: 0, approve: 1, reject: 2, cancelled: 3,
                        expired: 4, refunded: 5}, _prefix: :is
  attr_accessor :user_name, :phone, :football_pitch_n, :price

  UPDATE_ATTRS = [
    :user_id, :football_pitch_id, :discount_id,
    :booking_price, :start_at, :end_at, :price,
    :user_name, :phone, :football_pitch_n
  ].freeze
  # association
  belongs_to :user
  belongs_to :football_pitch
  belongs_to :discount, optional: true

  validates :start_at, presence: true
  validates :end_at, presence: true

  scope :newest, ->{order(created_at: :desc)}

  scope :search_by_booking_status, (lambda {|status|
    where(booking_status: status) if status.present?
  })

  scope :search_by_created_at, (lambda {|date|
    where(created_at: date.beginning_of_day..date.end_of_day) if date.present?
  })

  scope :search_by_start_at, (lambda {|date|
    where(start_at: date.beginning_of_day..date.end_of_day) if date.present?
  })

  delegate :name, :phone, to: :user, prefix: true, allow_nil: true
  delegate :name, :location, to: :football_pitch, prefix: true, allow_nil: true
  def overlaps_with_other_bookings?
    existing_bookings = football_pitch.bookings.where.not(id:)
    existing_bookings.each do |booking|
      if start_at && end_at && booking.start_at && booking.end_at &&
         start_at < booking.end_at && end_at > booking.start_at
        return true
      end
    end
    false
  end
end

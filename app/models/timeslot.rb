class Timeslot < ApplicationRecord
  belongs_to :challenge
  belongs_to :initiator, class_name: :Student, foreign_key: :initiator_id
  belongs_to :acceptor, class_name: :Student, foreign_key: :acceptor_id, required: false
  validates_presence_of :initiator_id, :challenge_id, :start_at, :end_at
  validate :must_start_before_end, :acceptor_must_be_diff_person
  scope :future, -> { where("start_at > ?", Time.now) }
  scope :not_mine, -> (student) { where("initiator_id != ?", student.id) }
  scope :soon, -> { where("start_at < ?", Time.now + 2.hours)}
  scope :not_soon, -> { where("start_at > ?", Time.now + 2.hours)}
  scope :no_pair, -> { where("acceptor_id IS NULL")}
  default_scope { order(start_at: :asc) }

  def self.clean_up
    self.where( start_at:(Time.now.midnight - 30.days)..Time.now.midnight).each do |timeslot|
      timeslot.destroy
    end
  end

  def time_zone
    self.initiator.time_zone
  end

  def must_start_before_end
    if start_at && end_at
      if start_at.to_date < DateTime.now.to_date
        errors.add(:start_date, "must be after #{DateTime.now.to_date}.")
      elsif (start_at.to_date == DateTime.now.to_date) && (start_at.strftime('%F%H:%M') < DateTime.now.strftime('%F%H:%M'))
        current_time = DateTime.now.strftime("%I:%M %p")
        errors.add(:start_time, "must be after #{current_time}.")
      elsif start_at.to_time > end_at.to_time
        errors.add(:start_time, "must be after end time.")
      end
    end
  end

  def acceptor_must_be_diff_person
    if self.acceptor == self.initiator
      errors.add(:acceptor, "cannot accept own timeslot")
    end
  end
end

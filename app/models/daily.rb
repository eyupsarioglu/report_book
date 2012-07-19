class Daily < ActiveRecord::Base
  attr_accessible :content, :status, :subject, :probation_id
  validates_presence_of :content, :subject
  validate :valid_date?

  def valid_date?
    pro = Probation.find(probation_id)
    if pro.daily.where("STRFTIME('%Y-%m-%d', created_at) = ?", DateTime.now.to_date).size > 0
      errors.add(:subject, "already exist for today")
    elsif pro.started_at > DateTime.now.to_date or pro.finished_at < DateTime.now.to_date
      errors.add(:probation_id, "time has expired")
    end
  end
  belongs_to :probation
  has_many :comment
end

class Probation < ActiveRecord::Base
  attr_accessible :finished_at, :firm_name, :probation_name, :probation_type, :started_at, :user_id
  validate :valid_date? => {:on => :create}

  def valid_date?
    if finished_at < started_at
      errors.add(:finished_at, "invalid! become started at <= finished at  ")
    elsif DateTime.now.to_date > started_at
      errors.add(:started_at, "invalid! become started at >= #{DateTime.now.to_date} ")
    elsif Probation.where("(finished_at BETWEEN ? AND ?) or (started_at BETWEEN ? AND ?) or (started_at <= ?
                            and finished_at >= ? )", started_at, finished_at, started_at, finished_at, started_at,
                              finished_at).size > 0
      errors.add(:started_at, "There is another probation betwen this dates ")
    end
  end
  has_many :daily
  has_many :image
  belongs_to :user
end

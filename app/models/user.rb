class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  EMAIL_REGEX = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.edu\.tr$/i

  validates :email, :presence => {:on => :create},
                    :uniqueness => true,
                    :format => {:with => EMAIL_REGEX,
                    :message => "is invalid, ....@...edu.tr"}

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :surname, :university, :department,
                  :academic_unit, :id, :role
  has_many :probation
  # attr_accessible :title, :body
end

class AdminUser < ActiveRecord::Base
  
  ROLES = %w(admin employee)
    
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable, :suspendable
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :first_name, :last_name, :email, :password, :password_confirmation, :remember_me, :role, :time_zone, :new_user, :send_welcome_email, :avatar, :github, :team_ids, :project_ids
  
  mount_uploader :avatar, AvatarUploader
    
  ROLES.each do |role|
    scope role.to_sym, where(["role = ?", role])
  end
  
  scope :sorted, order("lower(first_name) asc, lower(last_name) asc")
  scope :active, where("suspended_at IS NULL")
  scope :inactive, where("suspended_at IS NOT NULL")
  default_scope order("lower(first_name) asc, lower(last_name) asc")
    
  has_one :ticket_timer, dependent: :destroy
  has_and_belongs_to_many :projects, :join_table => "members_projects", :foreign_key => "member_id" do
    def ticket_ids
      find(:all, :include => :tickets).inject([]) { |ids, project| ids += project.ticket_ids }.uniq
    end
  end
  has_and_belongs_to_many :watched_tickets, :join_table => "tickets_watchers", :foreign_key => "watcher_id", :class_name => "Ticket"
  has_and_belongs_to_many :teams
  has_many :tickets, :foreign_key => "assignee_id", dependent: :nullify
  
  after_initialize :defaults
  
  validates :first_name, :presence => true
  validates :last_name, :presence => true
  validates :role, :presence => true, :inclusion => { :in => ROLES }
  validates :time_zone, :presence => true
  
  def full_name
    "%s %s" % [first_name, last_name]
  end
  alias_method :name, :full_name
  
  def reverse_name
    "#{last_name}, #{first_name}"
  end
  
  def role?(permission)
    self.role == permission.to_s.downcase
  end
  
  def admin?
    role? :admin
  end
  
  def employee?
    role? :employee
  end
  
  def display_name
    full_name
  end
  
  def welcomed?
    !new_user?
  end
  
  def welcome!
    self.update_attributes new_user: false
  end
  
  def github=(username)
    write_attribute :github, username.gsub(/http(s)?:\/\/(www.)?github.com\/?/, '').gsub("@", '')
  end
    
  protected 
  
    def defaults
      self.time_zone ||= Rails.application.config.time_zone rescue nil
    end
  
end

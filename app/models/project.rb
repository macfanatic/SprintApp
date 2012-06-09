class Project < ActiveRecord::Base
  
  has_paper_trail
  
  belongs_to :client
  belongs_to :product_owner, :class_name => "AdminUser", :foreign_key => :product_owner_id, :conditions => proc { ['role = ?', 'admin'] }
  has_and_belongs_to_many :members, :join_table => "members_projects", :association_foreign_key => :member_id, :class_name => "AdminUser"
  has_many :milestones, :dependent => :destroy, :order => "milestones.name asc"
  has_many :contacts, :through => :client
  has_many :tickets, dependent: :destroy
  has_many :project_files, dependent: :destroy
  
  scope :sorted, order("lower(projects.name) asc")
  scope :active, where("completed = ?", false)
  scope :closed, where("completed = ?", true)
  scope :recent, order('created_at desc, lower(projects.name) asc').limit(5)
  scope :owned_by, lambda { |owner| includes(:product_owner).where("admin_users.id = ?", owner.id).sorted }
  default_scope order("lower(projects.name) asc")
  
  validate :uniqueness_per_account, on: :create
  validates :number, presence: true, numericality: { integer_only: true, greater_than_or_equal_to: 0 }
  validates :name, :presence => true, :format => { :with => /\w+/, :message => "must contain letters" }
  validates :start_date, :presence => true
  validates :end_date, :date => { :after_or_equal_to => :start_date }, :allow_blank => true
  validates :product_owner_id, :client_id, :presence => true
  validates :client, :presence => true
  validates :hourly_rate, :presence => true, :numericality => { :greater_than_or_equal_to => 0 }
    
  delegate :name, :to => :client, :prefix => true
  
  after_initialize :set_default_values
  before_validation :determine_hourly_rate
  
  acts_as_url :name, limit: 100
  
  def display_name
    "##{number} #{client_name}: #{name}"
  end
  
  def switcher_name
    "#{client_name}: #{name} (##{number})"
  end
  
  def safe_end_date
    end_date.humanize rescue 'N/A'
  end
  
  def actual_time
    tickets.sum(:actual_time)
  end
  
  def estimated_time
    tickets.sum(:estimated_time)
  end
  
  def completion_percent
    return 0 if tickets.count == 0
    ((tickets.closed.count.to_f / tickets.active.count.to_f) * 100).round
  end
  
  def desired_completion_percent
    return 0 if tickets.should_be_closed_by_now.count == 0
    ((tickets.closed.count.to_f / tickets.should_be_closed_by_now.count.to_f) * 100).round
  end
  
  def budget_completion_percent
    return 0 if estimated_time == 0
    ((actual_time.to_f / estimated_time.to_f) * 100).round
  end
  
  def budget_desired_completion_percent
    affected_tickets = tickets.should_be_closed_by_now
    desired_budgeted_hours = affected_tickets.sum(:estimated_time)
    budgeted_hours = affected_tickets.sum(:actual_time)
    return 0 if budgeted_hours == 0
    [((desired_budgeted_hours.to_f / budgeted_hours.to_f) * 100).round, 100].min
  end
  
  def billable_time
    tickets.billable.sum(:actual_time)
  end
  
  def non_billable_time
    actual_time - billable_time
  end
  
  def archive!
    self.update_attribute :completed, true
  end
  
  def unarchive!
    self.update_attribute :completed, false
  end
  
  def to_param
    url
  end
  
  protected 
    
    def set_default_values
      if new_record?
        self.start_date ||= Date.today
        self.number ||= (Project.maximum(:number) + 1 rescue 1)
      end
    end
    
    def determine_hourly_rate
      unless self.client.nil?
        self.hourly_rate ||= self.client.hourly_rate
      end
    end
    
    def uniqueness_per_account
      errors.add(:number, "this number is already in use") if Project.exists? number: number
    end
  
end

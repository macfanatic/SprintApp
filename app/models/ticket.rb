class Ticket < ActiveRecord::Base
    
  has_paper_trail skip: [:budget_progress]
    
  belongs_to :milestone
  belongs_to :ticket_category
  belongs_to :ticket_priority
  belongs_to :status, :class_name => "TicketStatus", :foreign_key => "status_id"
  belongs_to :assignee, :class_name => "AdminUser"
  belongs_to :project
  has_and_belongs_to_many :watchers, :class_name => 'AdminUser', :association_foreign_key => "watcher_id", :join_table => "tickets_watchers", :order => "lower(admin_users.first_name) asc, lower(admin_users.last_name) asc"
  has_many :ticket_comments, :order => 'ticket_comments.created_at asc', :dependent => :destroy
  has_many :teams, :through => :assignee
  has_many :ticket_timers, dependent: :destroy
  
  accepts_nested_attributes_for :ticket_comments
  
  validates :name, :ticket_category, :ticket_priority, :status, :start_date, :description, :presence => true
  validates :estimated_time, :numericality => { :greater_than_or_equal_to => 0 }, :presence => true
  validates :actual_time, :numericality => { :greater_than_or_equal_to => 0 }, :allow_blank => true
  validates :end_date, :date => { :after_or_equal_to => :start_date }, :allow_blank => true
  validates :number, numericality: { integer_only: true }, presence: true
  
  validate :project_assignee_membership
  validate :project_watchers_membership
  validate :validate_start_date
  validate :uniqueness_per_account, on: :create
      
  scope :owned_by, lambda { |user| includes(:assignee).where("admin_users.id = ?", user.id) }
  scope :watched, lambda { |user| includes(:watchers).where("admin_users.id IN(?)", user.id) }
  scope :should_be_closed_by_now, includes(:status).where('tickets.end_date <= ?', Date.today)
  scope :recent, where("admin_users.created_at >= ?", 3.days.ago.to_date).order("admin_users.created_at asc")
  scope :active, includes(:status).where("ticket_statuses.active = ?", true)
  scope :closed, includes(:status).where("ticket_statuses.active = ?", false)
  scope :overdue, active.should_be_closed_by_now.order("tickets.name asc")
  scope :billable, where("tickets.billable = ?", true)
  scope :open_project, includes(:project).where(projects: { completed: false })
  
  # Everything that should have been started or finished by the end of the Sprint
  scope :current_sprint, where("tickets.start_date <= ? or tickets.end_date <= ?", Sprint.end_date, Sprint.end_date).active.includes(:assignee)
  
  delegate :email, :to => :assignee, :prefix => true, :allow_nil => true
  delegate :name, :display_name, :to => :project, :prefix => true, :allow_nil => true
    
  after_initialize :default_values
  before_create :default_end_date
  before_save :tally_time
  before_save :update_cached_progress
  
  acts_as_url :name, limit: 100
  
  def display_name
    '%s #%d' % [ticket_category.display_name, number]
  end
  
  def long_name
    "#{project.display_name} :: #{name}"
  end
  
  def informative_name
    "##{number} #{name}"
  end
  
  def budget_complete
    return 0 if estimated_time == 0
    time_perspective = ((actual_time.to_f / estimated_time.to_f) * 100).round
  end
  
  def safe_end_date
    end_date.humanize rescue 'N/A'
  end
  
  def priority
    ticket_priority.weight rescue 'normal'
  end
  
  def to_param
    url
  end
  
  def as_json(options={})
    options ||= {}
    {
      id: id,
      title: '%s - %s' % [display_name, name],
      start: start_date.strftime,
      end: (end_date.strftime rescue nil),
      allDay: true,
      className: priority,
      editable: options[:user].admin?,
      type: 'ticket',
      url: Rails.application.routes.url_helpers.project_ticket_path(self.project, self)
    }
  end
  
  def project_id=(p)
    write_attribute :project_id, p
    self.milestone = nil if milestone.present? && !project.milestones.pluck(:id).include?(milestone_id)
  end
  
  private
  
  def default_values
    if new_record?
      self.start_date ||= Date.today
      self.billable ||= true
      self.number ||= (Ticket.maximum(:number) + 1 rescue 1)
    end
  end
  
  def default_end_date
    self.end_date ||= (milestone.end_date.nil? ? milestone.project_end_date : milestone.end_date) rescue nil
  end
  
  def validate_start_date
    errors.add(:start_date, "Ticket cannot start after milestone has ended") if milestone.present? && milestone.end_date.present? && milestone.end_date < start_date
  end
  
  def project_assignee_membership
    errors.add(:assignee, "Assignee doesn't belong to project") if self.assignee.present? && !project.members.pluck(:id).include?(self.assignee_id)
  end
  
  def project_watchers_membership        
    project_members = project.members.map { |user| user.email }
    ticket_watchers = self.watchers.map { |user| user.email }
    problems = ticket_watchers - project_members
    errors.add(:watchers, '"%s" not assigned to project' % problems.join('", "')) unless problems.empty?
  end
  
  def tally_time
    self.actual_time = ticket_comments.to_a.sum(&:time)     
  end
  
  def update_cached_progress
    if actual_time_changed? or estimated_time_changed?
      if estimated_time == 0
        self.budget_progress = 0
      else
        self.budget_progress = actual_time.to_f / estimated_time.to_f
      end
    end
  end
  
  def uniqueness_per_account
    errors.add(:number, "this number is already in use") if Ticket.includes(:project).exists? number: number
  end
  
end

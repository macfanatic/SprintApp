class Milestone < ActiveRecord::Base
  
  belongs_to :project
  has_many :tickets, :dependent => :nullify
  
  validates :project, :presence => true
  validates :name, :presence => true
  validates :start_date, :presence => true
  validates :end_date, :date => { :after_or_equal_to => :start_date }, :allow_blank => true
  
  scope :active, where("milestones.completed = ?", false)
  scope :closed, where("milestones.completed = ?", true)
  scope :sorted, order("lower(milestones.name) asc")
  scope :should_be_closed_by_now, where("milestones.end_date <= ?", Date.today)
  scope :overdue, active.should_be_closed_by_now
  scope :current_sprint, where("milestones.start_date <= ? or milestones.end_date <= ?", Sprint.start_date, Sprint.end_date)
  default_scope order("lower(milestones.name) asc")
  
  after_initialize :default_date
  
  delegate :name, :end_date, :to => :project, :prefix => true, :allow_nil => true
  
  acts_as_url :name, limit: 100
  
  def default_date
    self.start_date ||= Date.today if new_record?
  end
  
  def display_name
    name
  end
  
  def long_name
    "#{project_name} - #{name}"
  end
  
  def safe_end_date
    end_date.humanize rescue 'N/A'
  end
  
  def num_tickets
    tickets.count
  end
  
  def num_open_tickets
    tickets.active.count
  end
  
  def num_closed_tickets
    tickets.closed.count
  end
  
  def completion_percent
    return 0 if num_tickets == 0
    ( (num_closed_tickets.to_f / num_tickets.to_f) * 100).round
  end
  
  def desired_completion_percent
    return 0 if num_tickets_should_be_closed_by_now == 0
    ( (num_tickets_should_be_closed_by_now.to_f / num_tickets.to_f) * 100).round
  end
  
  def num_tickets_should_be_closed_by_now
    tickets.should_be_closed_by_now.count
  end
  
  def budget_completion_percent
    return 0 if estimated_time == 0
    ((actual_time.to_f / estimated_time.to_f) * 100).round
  end
  
  def budget_desired_completion_percent
    affected_tickets = tickets.should_be_closed_by_now
    desired_budgeted_hours = affected_tickets.sum(:actual_time)
    budgeted_hours = affected_tickets.sum(:estimated_time)
    return 0 if budgeted_hours == 0
    [((desired_budgeted_hours.to_f / budgeted_hours.to_f) * 100).round, 100].min
  end
  
  def actual_time
    return 0 if tickets.count == 0
    tickets.sum(:actual_time)
  end
  
  def estimated_time
    return 0 if tickets.count == 0
    tickets.sum(:estimated_time)
  end
  
  def billable_time
    tickets.billable.sum(:actual_time)
  end
  
  def non_billable_time
    actual_time - billable_time
  end
  
  def as_json(options={})
    options ||= {}
    {
      id: id,
      title: long_name,
      start: start_date.strftime,
      end: (end_date.strftime rescue nil),
      allDay: true,
      className: 'normal',
      editable: options[:user].admin?,
      type: 'milestone',
      url: Rails.application.routes.url_helpers.project_milestone_path(self.project, self)
    }
  end
  
  def to_param
    url
  end
  
end

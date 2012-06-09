class Sprint
	
	def self.start_date
	  Date.today.wday == 1 ? Date.today : 1.week.ago.to_date.next_week  # Find the previous Monday, or today, if today is Monday
  end
  
  def self.end_date
    start_date.next_week - 1.day
  end
	
	def self.last_week
	  prev_start_date = start_date - 1.week
	  prev_end_date = start_date - 1.day
    prev_start_date.beginning_of_day..prev_end_date.end_of_day
  end
	
end
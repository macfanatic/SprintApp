module ProgressBarsHelper

  def milestone_progress_indicator(milestone, show_progress=true)
    progress_indicator(milestone.completion_percent, milestone.desired_completion_percent, show_progress)
  end

  def milestone_budget_progress_indicator(milestone, show_progress=true)
    budget_progress_indicator(milestone.budget_completion_percent, milestone.budget_desired_completion_percent, show_progress)
  end

  def billable_progress_indicator(project_or_milestone)
  
    billable = project_or_milestone.billable_time
    actual_time = project_or_milestone.actual_time
    percentage = ((billable / actual_time) * 100).round rescue 0  
    percentage = [percentage, 100].min
  
    red_percentage = percentage > 0 ? 100 : 0
    ('<div class="progress-indicator"><span class="progress red" style="width:%d%%;"></span><span class="progress green" style="width:%d%%"></span><span class="percent">%d%%</span></div>' % [red_percentage, percentage, percentage]).html_safe

  end

  def project_progress_indicator(project, show_progress=true)
    progress_indicator(project.completion_percent, project.desired_completion_percent, show_progress)
  end

  def project_budget_progress_indicator(project, show_progress=true)
    budget_progress_indicator(project.budget_completion_percent, project.budget_desired_completion_percent, show_progress)
  end

  def progress_indicator(percent, desired, show_progress=true)
    progress_label = show_progress ? '<span class="percent">%d%%</span>' % percent : nil
    capped_progress = [100, percent].min
    desired = [100, desired].min
    if percent < desired
      ('<div class="progress-indicator"><span class="progress grey" style="width:%d%%;"></span><span class="progress red" style="width:%d%%"></span>%s</div>' % [desired, capped_progress, progress_label]).html_safe
    else
      ('<div class="progress-indicator"><span class="progress light-green" style="width:%d%%;"></span><span class="progress green" style="width:%d%%"></span>%s</div>' % [capped_progress, desired, progress_label]).html_safe
    end
  end

  def budget_progress_indicator(actual, estimated, show_progress=true)
    progress_label = show_progress ? '<span class="percent">%d%%</span>' % actual : nil
    capped_actual = [100, actual].min
    estimated = [100, estimated].min
    if actual < estimated
      ('<div class="progress-indicator"><span class="progress light-green" style="width:%d%%;"></span><span class="progress green" style="width:%d%%"></span>%s</div>' % [estimated, capped_actual, progress_label]).html_safe
    else
      ('<div class="progress-indicator"><span class="progress red" style="width:%d%%"></span><span class="progress grey" style="width:%d%%;"></span>%s</div>' % [capped_actual, estimated, progress_label]).html_safe
    end
  end

  def simple_budget_progress_indicator(actual_time, estimated_time, show_progress=false)
    actual_percentage = ((actual_time.to_f / estimated_time.to_f) * 100).round rescue 0
    percentage = [100, actual_percentage].min
    progress_label = show_progress ? '<span class="percent">%d%%</span>' % actual_percentage : nil
    color = :green
    if percentage >= 65
      color = :orange
    end
    if percentage >= 95
      color = :red
    end
    ('<div class="progress-indicator"><span class="progress %s" style="width:%d%%"></span>%s</div>' % [color, percentage, progress_label]).html_safe
  end
  
end
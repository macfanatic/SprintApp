class Time
  def humanize
    strftime "%b %d, %Y %I:%M%p"
  end
end

class Date
  def humanize
    strftime "%b %d, %Y"
  end
end
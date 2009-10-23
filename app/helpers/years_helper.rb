module YearsHelper

  def format_year(year)
    h(year.to_s).sub('-', ' &ndash ')
  end

end

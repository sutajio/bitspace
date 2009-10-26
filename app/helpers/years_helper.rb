module YearsHelper

  def format_year(year)
    h(year.to_s).sub('-', ' &ndash; ').sub('..', ' &ndash; ')
  end

end

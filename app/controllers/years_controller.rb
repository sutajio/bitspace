class YearsController < ApplicationController
  
  def index
    @years = ((Time.now.year - 10)..Time.now.year).to_a.reverse.collect {|year| [year, current_user.releases.by_year(year).paginate(:page => 1, :per_page => 10)] }
    @years << ['2000-1990', current_user.releases.by_year(1990..2000).paginate(:page => 1, :per_page => 10)]
    @years << ['1990-1980', current_user.releases.by_year(1980..1990).paginate(:page => 1, :per_page => 10)]
    @years << ['1980-1970', current_user.releases.by_year(1970..1980).paginate(:page => 1, :per_page => 10)]
    @years << ['1970-1960', current_user.releases.by_year(1960..1970).paginate(:page => 1, :per_page => 10)]
    @years << ['1960-1950', current_user.releases.by_year(1950..1960).paginate(:page => 1, :per_page => 10)]
    @years << ['1950-1940', current_user.releases.by_year(1940..1950).paginate(:page => 1, :per_page => 10)]
    expires_in(5.minutes, :public => true)
  end
  
  def show
    @year = params[:id]
    if @year.split('-').size == 2
      years = @year.split('-').sort.map(&:to_i)
      years = years.first..years.last
    else
      years = @year
    end
    @releases = current_user.releases.by_year(years)
    expires_in(5.minutes, :public => true)
  end
  
end

class YearsController < ApplicationController
  
  skip_before_filter :require_user, :only => [:index, :show]
  before_filter :find_user, :only => [:index, :show]
  
  def index
    @years = (2000..Time.now.year).to_a.reverse.collect {|year| [year, @user.releases.without_archived.by_year(year).paginate(:page => 1, :per_page => 6)] }
    @years << ['1990-1999', @user.releases.without_archived.by_year(1990..1999).paginate(:page => 1, :per_page => 6)]
    @years << ['1980-1989', @user.releases.without_archived.by_year(1980..1989).paginate(:page => 1, :per_page => 6)]
    @years << ['1970-1979', @user.releases.without_archived.by_year(1970..1979).paginate(:page => 1, :per_page => 6)]
    @years << ['1960-1969', @user.releases.without_archived.by_year(1960..1969).paginate(:page => 1, :per_page => 6)]
    @years << ['1950-1959', @user.releases.without_archived.by_year(1950..1959).paginate(:page => 1, :per_page => 6)]
    @years << ['<1950', @user.releases.without_archived.by_year(0..1949).paginate(:page => 1, :per_page => 6)]
  end
  
  def show
    @year = params[:id]
    if @year.split('-').size == 2
      years = @year.split('-').sort.map(&:to_i)
      years = years.first..years.last
    elsif @year =~ /^\<[0-9]+/
      years = 0..(@year[1..-1].to_i-1)
    elsif @year =~ /^\>[0-9]+/
      years = (@year[1..-1].to_i+1)..Time.now.year
    else
      years = @year
    end
    @releases = @user.releases.without_archived.by_year(years)
  end
  
end

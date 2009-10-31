class YearsController < ApplicationController
  
  def index
    @years = ((Time.now.year - 10)..Time.now.year).to_a.reverse.collect {|year| [year, Release.by_year(year).all(:limit => 10)] }
    @years << ['2000-1990', Release.by_year(1990..2000).all(:limit => 10)]
    @years << ['1990-1980', Release.by_year(1980..1990).all(:limit => 10)]
    @years << ['1980-1970', Release.by_year(1970..1980).all(:limit => 10)]
    @years << ['1970-1960', Release.by_year(1960..1970).all(:limit => 10)]
    @years << ['1960-1950', Release.by_year(1950..1960).all(:limit => 10)]
    @years << ['1950-1940', Release.by_year(1940..1950).all(:limit => 10)]
    expires_in(5.minutes, :public => true)
  end
  
  def show
    @year = params[:id]
    if @year.split('-').size == 2
      years = @year.split('-').sort.map(&:to_i)
      @year = years.first..years.last
    end
    @releases = Release.by_year(@year)
    expires_in(5.minutes, :public => true)
  end
  
end

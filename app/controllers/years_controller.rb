class YearsController < ApplicationController
  
  def index
    @years = ((Time.now.year - 10)..Time.now.year).to_a.reverse.collect {|year| [year, Release.by_year(year)] }
    @years << ['2000-1990', Release.by_year(1990..2000)]
    @years << ['1990-1980', Release.by_year(1980..1990)]
    @years << ['1980-1970', Release.by_year(1970..1980)]
    @years << ['1970-1960', Release.by_year(1960..1970)]
    @years << ['1960-1950', Release.by_year(1950..1960)]
    @years << ['1950-1940', Release.by_year(1940..1950)]
  end
  
  def show
    @year = params[:id]
    @releases = Release.by_year(@year)
  end
  
end

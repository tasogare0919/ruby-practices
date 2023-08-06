#!/usr/bin/env ruby
require 'optparse'
require 'date'

def main
  argv_year, argv_month = year_and_month_from_argv
  year, month = year_and_month_to_i_with_default(argv_year, argv_month)
  weekday = ["日", "月", "火", "水", "木", "金", "土"]
  first_day = Date.new(year, month, 1)
  last_day = Date.new(year, month, -1).day
  wday_first = first_day.wday
  blank = "   " * wday_first
  puts "      #{first_day.strftime("%m") + '月'} #{year}"
  puts weekday.join(" ")
  print blank
  (1..last_day).each do |day|
    print day.to_s.rjust(2) + " "
    if (wday_first + day) % 7 == 0
      puts
    end
  end
end 

def year_and_month_from_argv
  opt = OptionParser.new
  params = {}
  opt.on('-y year', 'Calendar year designation') { |v| params[:year] = v }
  opt.on('-m month', 'Calendar month designation') { |v| params[:month] = v }
  opt.parse(ARGV)
  validate_year(params[:year])
  validate_month(params[:month])
  return params[:year], params[:month] 
end

def validate_year(year)
  if year != nil && (year.to_i < 1970 || year.to_i > 2100)
    abort "Invalid year: year #{year} not in range 1970..2100.Input year in range 1970..2100."
  end
end

def validate_month(month)
  if month != nil && (month.to_i < 1 || month.to_i > 12)
    abort "Invalid month: #{month} not in range 1..12.Input month in range 1..12."
  end
end

def year_and_month_to_i_with_default(year, month)
  year_with_default = year.nil? ? Date.today.year : year.to_i
  month_with_default = month.nil? ? Date.today.month : month.to_i
  return year_with_default, month_with_default
end

main

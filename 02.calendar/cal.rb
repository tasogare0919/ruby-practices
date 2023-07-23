#!/usr/bin/env ruby
require 'optparse'
require 'date'

def cal_params_init
    opt = OptionParser.new
    cal_params = {}
    opt.on('-y year', 'Calendar year designation') { |v| cal_params[:year] = v }
    opt.on('-m month', 'Calendar month designation') { |v| cal_params[:month] = v }
    opt.parse(ARGV)
    return cal_params[:year], cal_params[:month] 
end

def cal_year_month_set(year, month)
	cal_year = if year == nil
		Date.today.year
	else
		year.to_i
	end
	cal_month = if month == nil
			Date.today.month
		else 
			month.to_i
	end
	return cal_year, cal_month
end

cal_params_year, cal_params_month = cal_params_init()
cal_year, cal_month = cal_year_month_set(cal_params_year, cal_params_month)
cal_weekday = ["日", "月", "火", "水", "木", "金", "土"]
cal_first_day = Date.new(cal_year, cal_month, 1)
cal_last_day = Date.new(cal_year, cal_month, -1).day
cal_wday_first = cal_first_day.wday
cal_blank = "   " * cal_wday_first
# カレンダーを表示する.引数に何も指定がなければ今月のカレンダーを表示する.
puts "      #{cal_first_day.strftime("%B")} #{cal_year}"
puts cal_weekday.join(' ')
(1..cal_last_day).each do |day|
    print cal_blank if day == 1
    print day.to_s.rjust(2) + ' '
    if (cal_wday_first + day) % 7 == 0
        print "\n"
    end
end

#!/usr/bin/env ruby
require 'optparse'
require 'date'

this_year = Date.today.year
this_month = Date.today.month
weekday = ["日", "月", "火", "水", "木", "金", "土"]
first_day = Date.new(this_year, this_month, 1)
last_day = Date.new(this_year, this_month, -1).day
wday_first = first_day.wday
blank = "   " * wday_first

# カレンダーを表示する
# todo: 引数を取れるようにする、
puts "      #{Date.today.strftime("%B")} #{this_year}"
puts weekday.join(' ')
(1..last_day).each do |day|
    print blank if day == 1
    print day.to_s.rjust(2) + ' '
    if (wday_first + day) % 7 == 0
        print "\n"
    end
end
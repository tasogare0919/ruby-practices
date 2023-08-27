#!/usr/bin/env ruby
# frozen_string_literal: true

require 'debug'

score = ARGV[0]
scores = score.split(',')
shots = []
scores.each do |s|
  if s == 'X'
    shots << 10
    shots << 0
  else
    shots << s.to_i
  end
end

frames = []
shots.each_slice(2) do |s|
  frames << s
end

point = 0
frames.each.with_index do |frame, i|
  point += if frame[0] == 10 && i < 9
    if !frames[i + 2].nil? && frames[i + 1][0].to_i == 10 && frames[i + 2][0].to_i == 10
      30
    elsif frames[i + 1].nil? == false && frames[i + 1][0].to_i == 10 && frames[i + 2][0].to_i != 10
      20 + frames[i + 2][0].to_i
    else
      10 + frames[i + 1][0].to_i + frames[i + 1][1].to_i
    end
  elsif frame.sum == 10 && i < 9
    10 + frames[i + 1][0].to_i
  else
    frame.sum
  end
end
puts point

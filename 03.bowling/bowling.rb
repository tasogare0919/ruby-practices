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
frames.each_with_index do |frame,i|
  if frame[0] == 10 and i < 9
    point += 10 + frames[i+1][0].to_i + frames[i+1][1].to_i
  elsif frame.sum == 10 and i < 9
    point += 10 + frames[i+1][0].to_i
  elsif i >= 10
    point += frame.sum
  else
    point += frame.sum
  end
end
puts point

#!/usr/bin/env ruby
# frozen_string_literal: true

path = Dir.getwd
print Dir.glob("#{path}/*").map { |f| File.basename(f) }.join(' ')
print "\n"

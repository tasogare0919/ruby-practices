#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'

path = ARGV[0] || '.'
color = "\e[0m"

if File.directory?(path)
  Dir.glob("#{path}/*").each do |file|
    filename = File.basename(file)
    color = permission_color(file)
    print "#{color}#{filename}\e[0m "
  end
elsif File.file?(path)
  color = permission_color(path)
  print "#{color}#{File.basename(path)}\e[0m "
end
print "\n"

def permission_color(file)
  stat = File::Stat.new(file)
  if stat.directory?
    "\e[34m"
  elsif stat.executable?
    "\e[31m"
  end
end

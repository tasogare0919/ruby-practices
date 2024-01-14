#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'io/console'

path = ARGV[0] || '.'
terminal_width = IO.console.winsize[1]

def permission_color(file)
  stat = File::Stat.new(file)
  if stat.directory?
    "\e[34m"
  else 
    stat.executable? ? "\e[31m" : "\e[0m"
  end
end

if File.directory?(path)
  files = Dir.glob("#{path}/*").sort_by { |file| File.basename(file) }
  max_length = files.max_by { |file| File.basename(file).length }.length
  columns = terminal_width / (max_length + 1)
  files.each_slice(columns) do |slice|
    slice.each do |file|
      filename = File.basename(file)
      color = permission_color(file)
      print "#{color}#{filename.ljust(max_length)}\e[0m "
    end
    print "\n"
  end
elsif File.file?(path)
  color = permission_color(path)
  print "#{color}#{File.basename(path)}\e[0m "
else
  print "ls: #{path}: No such file or directory"
end
print "\n"

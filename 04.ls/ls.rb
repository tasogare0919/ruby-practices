#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.on('-r', 'Reverse the order of the sort') do |v|
    options[:r] = v
  end
end.parse!

COMMAND_OPTIONS = options
COLUMNS = 3

def print_file_by_column(files, first_row_count, display_max_lengths)
  COLUMNS.times do |column|
    next unless files[column] && files[column][first_row_count]

    filename = File.basename(files[column][first_row_count])
    color = permission_color(files[column][first_row_count])
    print "#{color}#{filename.ljust(display_max_lengths[column])}\t\e[0m "
  end
end

def print_files(files, display_max_lengths)
  files.first.size.times do |first_row_count|
    print_file_by_column(files, first_row_count, display_max_lengths)
    print "\n"
  end
end

def sort_files(files)
  files.sort_by { |file| File.basename(file)}
end

def fetch_and_sort_files(path)
  files = Dir.glob("#{path}/*")
  sort_files(files).send(COMMAND_OPTIONS[:r] ? :reverse : :itself)
end

def display_max_lengths(files)
  files.map do |column|
    column.map(&:size).max
  end
end

def permission_color(file)
  stat = File::Stat.new(file)
  if stat.directory?
    "\e[34m"
  else
    stat.executable? ? "\e[31m" : "\e[0m"
  end
end

def handle_directory(path)
  files = fetch_and_sort_files(path)
  files = files.each_slice((files.size / COLUMNS.to_f).ceil).to_a
  display_max_lengths = display_max_lengths(files)
  print_files(files, display_max_lengths)
end

def handle_file(path)
  color = permission_color(path)
  print "#{color}#{File.basename(path)}\e[0m "
end

def handle_path(path)
  if File.directory?(path)
    handle_directory(path)
  elsif File.file?(path)
    handle_file(path)
  else
    print "ls: #{path}: No such file or directory"
  end
end

def main
  path = ARGV[0] || '.'
  handle_path(path)
  print "\n"
end

main

#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

COLUMNS = 3

def command_options_from_argv
  options = {}
  OptionParser.new do |opts|
    opts.on('-a', 'Include directory entries whose names begin with a dot (".")') do |v|
      options[:a] = v
    end
  end.parse!
  options
end

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

def fetch_and_sort_files(command_options, path)
  files = if command_options[:a]
            Dir.glob("#{path}/*", File::FNM_DOTMATCH)
          else
            Dir.glob("#{path}/*")
          end
  files.sort_by { |file| File.basename(file) }
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

def handle_directory(path, command_options)
  files = fetch_and_sort_files(command_options, path)
  files = files.each_slice((files.size / COLUMNS.to_f).ceil).to_a
  display_max_lengths = display_max_lengths(files)
  print_files(files, display_max_lengths)
end

def handle_file(path)
  color = permission_color(path)
  print "#{color}#{File.basename(path)}\e[0m "
end

def handle_path(path, command_options)
  if File.directory?(path)
    handle_directory(path, command_options)
  elsif File.file?(path)
    handle_file(path)
  else
    print "ls: #{path}: No such file or directory"
  end
end

def main
  command_options = command_options_from_argv
  path = ARGV[0] || '.'
  handle_path(path, command_options)
  print "\n"
end

main

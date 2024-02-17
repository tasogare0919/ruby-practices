#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def command_options_from_argv
  options = {}
  OptionParser.new do |opts|
    opts.on('-a', 'Include directory entries whose names begin with a dot (".")') do |v|
      options[:a] = v
    end
  end.parse!
  options
end

def print_file_by_column(files, index, columns, max_length)
  columns.times do |j|
    next unless files[j] && files[j][index]

    filename = File.basename(files[j][index])
    color = permission_color(files[j][index])
    print "#{color}#{filename.ljust(max_length[j])}\t\e[0m "
  end
end

def print_files(files, columns, max_length)
  files.first.size.times do |index|
    print_file_by_column(files, index, columns, max_length)
    print "\n"
  end
end

def fetch_and_sort_files(command_options, path)
  if command_options[:a]
    Dir.glob("#{path}/*", File::FNM_DOTMATCH).sort_by { |file| File.basename(file) }
  else
    Dir.glob("#{path}/*").sort_by { |file| File.basename(file) }
  end
end

def display_max_length(files)
  files.map do |column|
    column.map { |file| File.basename(file).length }.max
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

def handle_directory(path, command_options, columns)
  files = fetch_and_sort_files(command_options, path)
  files = files.each_slice((files.size / columns.to_f).ceil).to_a
  max_length = display_max_length(files)
  print_files(files, columns, max_length)
end

def handle_file(path)
  color = permission_color(path)
  print "#{color}#{File.basename(path)}\e[0m "
end

def handle_path(path, command_options, columns)
  if File.directory?(path)
    handle_directory(path, command_options, columns)
  elsif File.file?(path)
    handle_file(path)
  else
    print "ls: #{path}: No such file or directory"
  end
end

def main
  columns = 3
  command_options = command_options_from_argv
  path = ARGV[0] || '.'
  handle_path(path, command_options, columns)
  print "\n"
end

main

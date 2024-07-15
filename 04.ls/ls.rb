#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'

options = {}
OptionParser.new do |opts|
  opts.on('-l', 'List files in the long format') do |v|
    options[:l] = v
  end
end.parse!

COMMAND_OPTIONS = options
COLUMNS = 3

def file_mode(mode)
  type = case mode & 0170000
         when 0140000 then 's'
         when 0120000 then 'l'
         when 0100000 then '-'
         when 0060000 then 'b'
         when 0040000 then 'd'
         when 0020000 then 'c'
         else '?'
         end

  permission = ['r', 'w', 'x'].map do |p|
    [4, 2, 1].map { |b| mode & b != 0 ? p : '-' }.join
  end.join

  "#{type}#{permission}"
end

def calculate_total_blocks(path)
  total = 0
  Dir.glob(File.join(path, '*'), File::FNM_DOTMATCH) do |file|
    next if File.basename(file) == '.' || File.basename(file) == '..' || File.basename(file).start_with?('.')
    stat = File.lstat(file)
    total += stat.blocks
  end
  total
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
    if COMMAND_OPTIONS[:l]
      file_path = files[0][first_row_count]
      stat = File.stat(file_path)
      puts "#{file_mode(stat.mode)} #{stat.nlink} #{Etc.getpwuid(stat.uid).name} #{Etc.getgrgid(stat.gid).name} #{stat.size.to_s.rjust(8)} #{stat.mtime.strftime('%b %d %H:%M')} #{File.basename(file_path)}"
    else
      print_file_by_column(files, first_row_count, display_max_lengths)
      print "\n"
    end
  end
end

def sort_files(files)
  files.sort_by { |file| File.basename(file) }
end

def fetch_and_sort_files(path)
  files = Dir.glob("#{path}/*")
  sorted_files = sort_files(files)
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
  if COMMAND_OPTIONS[:l]
    total_blocks = calculate_total_blocks(path)
    puts "total #{total_blocks}"
    files.each do |file|
      print_files([[file]], [] )
    end
  else
    files = files.each_slice((files.size / COLUMNS.to_f).ceil).to_a
    display_max_lengths = display_max_lengths(files)
    print_files(files, display_max_lengths)
  end
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

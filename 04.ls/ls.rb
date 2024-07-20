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
  type = file_type(mode)
  permission = file_permission(mode)
  "#{type}#{permission}"
end

def file_type(mode)
  case mode & 0o170000
  when 0o140000 then 's'
  when 0o120000 then 'l'
  when 0o100000 then '-'
  when 0o060000 then 'b'
  when 0o040000 then 'd'
  when 0o020000 then 'c'
  else '?'
  end
end

def file_permission(mode)
  %w[r w x].map do |p|
    [4, 2, 1].map { |b| mode & b != 0 ? p : '-' }.join
  end.join
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
      print_file_long_format(files, first_row_count)
    else
      print_file_by_column(files, first_row_count, display_max_lengths)
      print "\n"
    end
  end
end

def print_file_long_format(files, first_row_count)
  file_info = fetch_file_info(files[0][first_row_count])
  puts file_info.join(' ')
end

def fetch_file_info(file_path)
  stat = File.stat(file_path)
  mode = file_mode(stat.mode)
  nlink = stat.nlink
  uid = fetch_uid(stat.uid)
  gid = fetch_gid(stat.gid)
  size = fetch_size(stat.size)
  mtime = fetch_mtime(stat.mtime)
  basename = File.basename(file_path)
  [mode, nlink, uid, gid, size, mtime, basename]
end

def fetch_uid(uid)
  Etc.getpwuid(uid).name
end

def fetch_gid(gid)
  Etc.getgrgid(gid).name
end

def fetch_size(size)
  size.to_s.rjust(8)
end

def fetch_mtime(mtime)
  mtime.strftime('%b %d %H:%M')
end

def sort_files(files)
  files.sort_by { |file| File.basename(file) }
end

def fetch_and_sort_files(path)
  files = Dir.glob("#{path}/*")
  sort_files(files)
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
    handle_long_format(path, files)
  else
    handle_column_format(files)
  end
end

def handle_long_format(path, files)
  total_blocks = calculate_total_blocks(path)
  puts "total #{total_blocks}"
  files.each do |file|
    print_files([[file]], [])
  end
end

def handle_column_format(files)
  files = file.each.slice((files.size / COLUMNS.to_f).ceil).to_a
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

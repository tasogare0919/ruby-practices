#!/usr/bin/env ruby
# frozen_string_literal: true

path = ARGV[0] || '.'
columns = 3

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
  files = files.each_slice((files.size / columns.to_f).ceil).to_a
  max_length = files.map do |column|
    column.map { |file| File.basename(file).length }.max
  end
  files.first.size.times do |i|
    columns.times do |j|
      next unless files[j] && files[j][i]

      filename = File.basename(files[j][i])
      color = permission_color(files[j][i])
      print "#{color}#{filename.ljust(max_length[j])}\t\e[0m "
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

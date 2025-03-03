#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'

class LsCommand
  COLUMNS = 3.freeze
  PERMISSIONS = {
    '7' => 'rwx',
    '6' => 'rw-',
    '5' => 'r-x',
    '4' => 'r--',
    '3' => '-wx',
    '2' => '-w-',
    '1' => '--x',
    '0' => '---'
  }.freeze

  def initialize(args = ARGV)
    @options = parse_options(args)
    @path = args[0] || '.'
  end

  def run
    handle_path(@path)
    print "\n"
  end

  private

  def parse_options(args)
    options = {}
    OptionParser.new do |opts|
      opts.on('-l', 'List files in the long format') do |v|
        options[:l] = v
      end
    end.parse!
    options
  end

end

if __FILE__ == $PROGRAM_NAME
  LsCommand.new.run
end

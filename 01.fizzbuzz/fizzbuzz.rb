#!/usr/bin/env ruby
require 'debug'

def fizzbuzz(count)
    if count % 15 == 0 then
        puts "FizzBuzz"
    elsif count % 5 == 0 then
        puts "Buzz"
    elsif count % 3 == 0 then
        puts "Fizz"
    else
        puts count
    end
end

(1..20).each do |count|
    binding.break
    fizzbuzz(count)
end

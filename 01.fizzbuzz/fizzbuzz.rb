
count = 1
while count <= 20
    if count % 15 == 0 then
        puts "FizzBuzz"
    elsif count % 5 == 0 then
        puts "Buzz"
    elsif count % 3 == 0 then
        puts "Fizz"
    else
        puts count
    end
    count += 1  
end
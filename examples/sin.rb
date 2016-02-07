# Example using sin wave function
require_relative '../lib/brainy'
net = Brainy::Network.new(1, 3, 1, 0.25)

# training
4000.times do
  i = rand(0..(Math::PI/2))
  o = Math.sin(i)
  net.train!([i], [o])
end

# testing
mse = 1000.times.map do
  i = rand(0..(Math::PI/2))
  o = Math.sin(i)
  (o - net.evaluate([i]).first) ** 2
end.reduce(:+) / 1000

puts "your MSE: #{ mse.round(3) }"

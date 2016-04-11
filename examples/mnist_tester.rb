# Example testing loaded net (mnist.yaml) for % answers correct
# NOTE: this is a time consuming script, took ~20 minutes on my MacBook Pro (using JRuby)
#
# MNIST dataset files not included, get them here:
# http://yann.lecun.com/exdb/mnist/
# MNIST loading code based off code from here:
# https://github.com/gbuesing/mnist-ruby-test/blob/master/train/mnist_loader.rb

require 'zlib'
require_relative '../lib/brainy'

puts 'loading test data...'
labels, images = nil, nil
Zlib::GzipReader.open('t10k-labels-idx1-ubyte.gz') do |file|
  magic, n_labels = file.read(8).unpack('N2')
  raise 'This is not MNIST label file' if magic != 2049
  labels = file.read(n_labels).unpack('C*').map { |label| Array.new(10) { |i| i == label ? 1.0 : 0.0 }}
end

Zlib::GzipReader.open('t10k-images-idx3-ubyte.gz') do |file|
  magic, n_images = file.read(8).unpack('N2')
  raise 'This is not MNIST image file' if magic != 2051
  n_rows, n_cols = file.read(8).unpack('N2')
  images = file.read(n_images * n_rows * n_cols).unpack('C*').each_slice(n_rows * n_cols)
end

puts 'testing data...'
net = Brainy::Network.from_serialized('mnist.yaml')
test_data = labels.zip(images)
correct = test_data.each_with_index.map do |example, idx|
  expected, inputs = example
  output = net.evaluate(inputs).to_a
  print ("\r%% %.3f" % (100 * idx.to_f / test_data.length)).ljust(20, ' ')
  output.index(output.max) == expected.index(expected.max) ? 1 : 0
end.reduce(:+)
print "\r% 100.000".ljust(20, ' ') + "\n"
puts 'correct answers: %% %.2f' % (100.0 * correct / test_data.length)

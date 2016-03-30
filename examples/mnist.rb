# Example training using MNIST OCR set
# MNIST dataset files not included, get them here:
# http://yann.lecun.com/exdb/mnist/
# MNIST loading code based off code from here:
# https://github.com/gbuesing/mnist-ruby-test/blob/master/train/mnist_loader.rb

require 'zlib'
require_relative '../lib/brainy'

puts 'loading train/test data...'
label_filenames = %w(train-labels-idx1-ubyte.gz t10k-labels-idx1-ubyte.gz)
training_labels, testing_labels = label_filenames.reduce([]) do |sets, filename|
  Zlib::GzipReader.open(filename) do |file|
    magic, n_labels = file.read(8).unpack('N2')
    raise 'This is not MNIST label file' if magic != 2049
    sets << file.read(n_labels).unpack('C*').map { |label| Array.new(10) { |i| i == label ? 1.0 : 0.0 }}
  end
end

image_filenames = %w(train-images-idx3-ubyte.gz t10k-images-idx3-ubyte.gz)
training_images, testing_images = image_filenames.reduce([]) do |sets, filename|
  Zlib::GzipReader.open(filename) do |file|
    magic, n_images = file.read(8).unpack('N2')
    raise 'This is not MNIST image file' if magic != 2051
    n_rows, n_cols = file.read(8).unpack('N2')
    sets << file.read(n_images * n_rows * n_cols).unpack('C*').each_slice(n_rows * n_cols)
  end
end

training_data = training_labels.zip(training_images)
testing_data = testing_labels.zip(testing_images)

puts 'training...'
net = Brainy::Network.new(784, 300, 10)
training_data.each_with_index do |datum, idx|
  expected, inputs = datum
  net.train!(inputs, expected)
  print ("\r%% %f" % (100.0 * idx / training_data.length)).ljust(20, ' ')
end
print "\r% 100!".ljust(20, ' ') + "\n"

puts 'testing...'
mse = testing_data.each_with_index.map do |datum, idx|
  expected, inputs = datum
  output = net.evaluate(inputs).zip(expected).map { |x, y| (x - y) ** 2 }.reduce(:+) / 10
  print ("\r%% %f" % (100 * idx.to_f / testing_data.length)).ljust(20, ' ')
  output
end.reduce(:+) / testing_data.count
print "\r% 100!".ljust(20, ' ') + "\n"
puts "\nMSE: #{mse}"

File.open('mnist.yaml', 'w') { |file| file.write(net.serialize) }

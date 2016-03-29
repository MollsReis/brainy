# Example training using MNIST OCR set
# MNIST dataset files not included, get them here:
# http://yann.lecun.com/exdb/mnist/
# MNIST loading code based off code from here:
# https://github.com/gbuesing/mnist-ruby-test/blob/master/train/mnist_loader.rb

require 'zlib'
require_relative '../lib/brainy'

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

net = Brainy::Network.new(784, 280, 10)
training_data.each do |datum|
  expected, inputs = datum
  net.train!(inputs, expected)
end

mse = testing_data.map do |datum|
  expected, inputs = datum
  net.evaluate(inputs).zip(expected).map { |x, y| (x - y) ** 2 }.reduce(:+) / 10
end.reduce(:+) / testing_data.count
puts "MSE: #{mse}"

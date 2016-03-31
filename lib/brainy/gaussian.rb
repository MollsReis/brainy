require 'java'

module Brainy
  java_import java.util.Random

  class Gaussian
    def initialize
      @rand = Random.new
    end

    def next
      @rand.nextGaussian * 0.1
    end
  end
end

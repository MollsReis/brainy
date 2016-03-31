require 'java'

module Brainy
  java_import java.util.Random

  class Gaussian
    @rand = Random.new

    def self.next
      @rand.nextGaussian * 0.1
    end
  end
end

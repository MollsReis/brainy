module Brainy
  java_import java.util.Random

  class Gaussian
    @rand = Random.new

    def self.next
      @rand.nextGaussian
    end
  end
end

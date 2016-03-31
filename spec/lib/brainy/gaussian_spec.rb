require_relative '../../spec_helper'

module Brainy
  describe Gaussian do
    let (:rand) { Gaussian.new }

    describe '#initialize' do
      it 'creates a Java Random object' do
        expect(rand.instance_variable_get(:@rand)).to_not be_nil
      end
    end

    describe '#next' do
      it 'returns a random number in the normal distribution' do
        expect(rand.next).to be_a Float
      end
    end

  end
end

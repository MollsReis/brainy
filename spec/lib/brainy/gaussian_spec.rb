require_relative '../../spec_helper'

module Brainy
  describe Gaussian do
    describe '.next' do
      it 'returns a random number in the normal distribution' do
        expect(Gaussian.next).to be_a Float
      end
    end

  end
end

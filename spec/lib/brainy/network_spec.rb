require_relative '../../spec_helper'

module Brainy
  describe Network do
    let (:net) { Network.new(4, 3, 2) }

    describe '#initialize' do
      it 'creates a network with random weights' do
        weights = net.layers.flatten.map(&:to_a).flatten
        expect(weights.count).to eq weights.uniq.count
      end
    end

    describe '#evaluate' do
      it 'evaluates the network for a set of inputs' do
        net.instance_variable_set(:@layers, [
            JMatrix.new([
                [0.1, 0.2, 0.3, 0.4, 0.5],
                [0.5, 0.6, 0.7, 0.8, 0.9],
                [0.9, 0.1, 0.2, 0.3, 0.4]
            ]),
            JMatrix.new([
                [0.1, 0.2, 0.3, 0.4],
                [0.4, 0.5, 0.6, 0.5]
            ])
        ])
        out = net.evaluate([0.1, 0.3, 0.5, 0.7]).map { |x| x.round(6) }
        expect(out).to eq [0.702451, 0.839256]
      end
    end

    describe '#get_output_deltas' do
      it 'provides deltas for the output layer' do
        expected, output = [0.4, 0.6], [0.3, 0.8]
        deltas = net.get_output_deltas(expected, output)
        expect(deltas.map { |x| x.round(6) }).to eq [-0.021, 0.032]
      end
    end

    describe '#get_hidden_deltas' do
      it 'provides deltas for the hidden layer' do
        hidden_outs, output_deltas = [0.9, 0.8, 0.7, 1.0], [0.6, 0.4]
        output_nodes = JMatrix.new([[0.2, 0.3, 0.4], [0.4, 0.3, 0.2]])
        deltas = net.get_hidden_deltas(hidden_outs, output_nodes, output_deltas)
        expect(deltas.map { |x| x.round(6) }).to eq [0.0252, 0.048, 0.0672]
      end
    end

    describe '#get_updated_weights' do
      it 'updates the hidden weights' do
        layer = JMatrix.new([
            [0.3, 0.4, 0.5, 0.6],
            [0.1, 0.2, 0.4, 0.8],
            [0.9, 0.6, 0.3, 0.0]
        ])
        inputs, deltas = [0.2, 0.3, 0.4, 0.5], [0.7, 0.6, 0.5]
        new_layer = net.get_updated_weights(layer, inputs, deltas)
        expected = [
            [0.265, 0.3475, 0.43, 0.5125],
            [0.07, 0.155, 0.34, 0.725],
            [0.875, 0.5625, 0.25, -0.0625]
        ]
        expect(new_layer.map { |x| x.round(6) }).to eq expected
      end
    end
  end
end

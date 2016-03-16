module Brainy
  class Network
    attr_accessor :layers

    def initialize(input_count, hidden_count, output_count, learning_rate)
      @layers = [
          Matrix.build(hidden_count, input_count + 1) { rand(-1.0..1.0) },
          Matrix.build(output_count, hidden_count + 1) { rand(-1.0..1.0) }
      ]
      @learning_rate = learning_rate
    end

    def activate(x)
      1 / (1 + Math.exp(-1 * x))
    end

    def activate_prime(x)
      x * (1 - x)
    end

    def evaluate(inputs)
      @layers.reduce(Vector.elements(inputs)) do |input, layer|
        (layer * Vector.elements(input.to_a + [1.0])).map { |v| activate(v) }
      end
    end

    def train!(inputs, expected)
      inputs = Vector.elements(inputs + [1.0])
      hidden_outs = Vector.elements((@layers.first * inputs).map { |v| activate(v) }.to_a + [1.0])
      output_outs = (@layers.last * hidden_outs).map { |v| activate(v) }
      output_deltas = get_output_deltas(expected, output_outs)
      hidden_deltas = get_hidden_deltas(hidden_outs, @layers.last, output_deltas)
      @layers[1] = get_updated_weights(@layers.last, hidden_outs, output_deltas)
      @layers[0] = get_updated_weights(@layers.first, inputs, hidden_deltas)
    end

    def get_output_deltas(expected, output)
      expected.zip(output).map do |expect, out|
        (out - expect) * activate_prime(out)
      end
    end

    def get_hidden_deltas(hidden_outs, output_nodes, output_deltas)
      hidden_outs.each_with_index.map do |out, index|
        output_nodes.row_vectors.zip(output_deltas)
            .map { |weights, delta| weights[index] * delta }
            .reduce(:+) * activate_prime(out)
      end
    end

    def get_updated_weights(layer, inputs, deltas)
      Matrix.rows(layer.row_vectors.each_with_index.map do |weights, node_index|
        Vector.elements(weights.each_with_index.map do |weight, weight_index|
          weight - (@learning_rate * inputs[weight_index] * deltas[node_index])
        end)
      end)
    end

    def serialize
      YAML.dump(self)
    end

    def self.from_serialized(dump)
      net = YAML.load(dump)
      net.instance_variable_set(:@activate, lambda { |x| 1 / (1 + Math.exp(-1 * x)) })
      net.instance_variable_set(:@activate_prime, lambda { |x| x * (1 - x) })
      net
    end
  end
end

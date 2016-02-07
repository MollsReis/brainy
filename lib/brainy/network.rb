module Brainy
  class Network
    attr_accessor :hidden_layer, :output_layer

    def initialize(input_count, hidden_count, output_count, learning_rate)
      @layers = [
          Array.new(hidden_count, Vector.elements(Array.new(input_count + 1, rand(-1.0..1.0)))),
          Array.new(output_count, Vector.elements(Array.new(hidden_count + 1, rand(-1.0..1.0))))
      ]
      @learning_rate = learning_rate
      @activate = lambda { |x| 1 / (1 + Math.exp(-1 * x)) }
      @activate_prime = lambda { |x| x * (1 - x) }
    end

    def evaluate(inputs)
      @layers.reduce(Vector.elements(inputs)) do |input, layer|
        input = Vector.elements(input.to_a + [1])
        output = layer.map { |node| @activate.call(node.inner_product(input)) }
        Vector.elements(output)
      end
    end

    def train!(inputs, expected)
      inputs = Vector.elements(inputs + [1])
      hidden_outs = Vector.elements(@layers.first.map { |node| @activate.call(node.inner_product(inputs)) } + [1])
      output_outs = Vector.elements(@layers.last.map { |node| @activate.call(node.inner_product(hidden_outs)) })
      output_deltas = get_output_deltas(expected, output_outs)
      hidden_deltas = get_hidden_deltas(hidden_outs, @layers.last, output_deltas)
      @layers[1] = get_updated_weights(@layers.last, hidden_outs, output_deltas)
      @layers[0] = get_updated_weights(@layers.first, inputs, hidden_deltas)
    end

    def get_output_deltas(expected, output)
      expected.zip(output.to_a).map do |expect, out|
        (out - expect) * @activate_prime.call(out)
      end
    end

    def get_hidden_deltas(hidden_outs, output_nodes, output_deltas)
      hidden_outs.each_with_index.map do |out, index|
        error = output_nodes.zip(output_deltas).map { |weights, delta| weights[index] * delta }.reduce(:+)
        error * @activate_prime.call(out)
      end
    end

    def get_updated_weights(layer, inputs, deltas)
      layer.each_with_index.map do |weights, node_index|
        weights = weights.each_with_index.map do |weight, weight_index|
          weight - (@learning_rate * inputs[weight_index] * deltas[node_index])
        end
        Vector.elements(weights)
      end
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

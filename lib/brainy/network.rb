module Brainy
  class Network
    attr_accessor :layers

    def initialize(input_count, hidden_count, output_count, options = {})
      options = default_options.update(options)
      @learning_rate = options[:learning_rate]
      @activate = options[:activate]
      @activate_prime = options[:activate_prime]
      @weight_init = options[:weight_init]
      @layers = [
          Matrix.build(hidden_count, input_count + 1) { @weight_init.call },
          Matrix.build(output_count, hidden_count + 1) { @weight_init.call }
      ]
    end

    def default_options
      {
          learning_rate: 0.25,
          activate: lambda { |x| 1 / (1 + Math.exp(-1 * x)) },
          activate_prime: lambda { |x| x * (1 - x) },
          weight_init: lambda { rand(-1.0..1.0) }
      }
    end

    def evaluate(inputs)
      @layers.reduce(Vector.elements(inputs)) do |input, layer|
        (layer * Vector.elements(input.to_a + [1.0])).map(&@activate)
      end
    end

    def train!(inputs, expected)
      inputs = Vector.elements(inputs + [1.0])
      hidden_outs = Vector.elements((@layers.first * inputs).map(&@activate).to_a + [1.0])
      output_outs = (@layers.last * hidden_outs).map(&@activate)
      output_deltas = get_output_deltas(expected, output_outs)
      hidden_deltas = get_hidden_deltas(hidden_outs, @layers.last, output_deltas)
      @layers[1] = get_updated_weights(@layers.last, hidden_outs, output_deltas)
      @layers[0] = get_updated_weights(@layers.first, inputs, hidden_deltas)
    end

    def get_output_deltas(expected, output)
      expected.zip(output).map do |expect, out|
        (out - expect) * @activate_prime.call(out)
      end
    end

    def get_hidden_deltas(hidden_outs, output_nodes, output_deltas)
      hidden_outs.each_with_index.map do |out, index|
        output_nodes.row_vectors.zip(output_deltas)
            .map { |weights, delta| weights[index] * delta }
            .reduce(:+) * @activate_prime.call(out)
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

    def self.from_serialized(dump, options = {})
      net = YAML.load(dump.class == File ? dump : File.open(dump))
      options = net.default_options.update(options)
      net.instance_variable_set(:@activate, options[:activate])
      net.instance_variable_set(:@activate_prime, options[:activate_prime])
      net.instance_variable_set(:@weight_init, options[:weight_init])
      net
    end
  end
end

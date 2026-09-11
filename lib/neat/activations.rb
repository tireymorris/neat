module NEAT
  module Activations
    def self.call(name, x)
      case name
      when :sigmoid
        1.0 / (1.0 + Math.exp(-4.9 * x))
      when :tanh
        Math.tanh(x)
      when :relu
        x > 0.0 ? x : 0.0
      when :linear
        x
      when :step
        x > 0.0 ? 1.0 : 0.0
      else
        raise Error, "Unknown activation: #{name}"
      end
    end
  end
end

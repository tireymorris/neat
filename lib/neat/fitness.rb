module NEAT
  module Fitness
    def self.evaluator(cases, output_index: 0, &transform)
      lambda do |genome|
        error = cases.sum do |inputs, target|
          (genome.evaluate(inputs)[output_index] - target).abs
        end
        transform ? transform.call(error) : -error
      end
    end

    def self.solved?(genome, cases, output_index: 0, tolerance: 0.5)
      cases.all? do |inputs, target|
        (genome.evaluate(inputs)[output_index] - target).abs < tolerance
      end
    end
  end
end

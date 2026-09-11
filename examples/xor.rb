#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../lib/neat"

XOR_CASES = [
  [[1.0, 0.0, 0.0], 0.0],
  [[1.0, 0.0, 1.0], 1.0],
  [[1.0, 1.0, 0.0], 1.0],
  [[1.0, 1.0, 1.0], 0.0]
].freeze

fitness = NEAT::Fitness.evaluator(XOR_CASES) { |error| (4.0 - error)**2 }

config = NEAT::Config.new.tap do |c|
  c.population_size = 150
  c.inputs = 3
  c.outputs = 1
  c.compatibility_threshold = 3.0
  c.add_connection_rate = 0.3
  c.add_node_rate = 0.1
  c.bias_mutation_rate = 0.0 # explicit bias input
  c.activation_mutation_rate = 0.0
  c.seed = 1
end

population = NEAT::Population.new(config)

100.times do |generation|
  population.evaluate!(&fitness)
  best = population.best
  outputs = XOR_CASES.map { |inputs, _| best.evaluate(inputs).first.round(3) }
  puts "gen=#{generation} fitness=#{best.fitness.round(3)} outputs=#{outputs}"
  break if NEAT::Fitness.solved?(best, XOR_CASES)

  population.evolve!
end

population.evaluate!(&fitness)
best = population.best
puts "best fitness=#{best.fitness.round(3)}"
XOR_CASES.each do |inputs, target|
  output = best.evaluate(inputs).first
  puts "  #{inputs[1].to_i} XOR #{inputs[2].to_i} => #{output.round(4)} (target #{target.to_i})"
end

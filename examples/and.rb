#!/usr/bin/env ruby
# frozen_string_literal: true

# Evolve a feedforward net for logical AND (2 inputs → 1 output).
require_relative "../lib/neat"

AND_CASES = [
  [[0.0, 0.0], 0.0],
  [[0.0, 1.0], 0.0],
  [[1.0, 0.0], 0.0],
  [[1.0, 1.0], 1.0]
].freeze

fitness = NEAT::Fitness.evaluator(AND_CASES) { |error| (4.0 - error)**2 }

config = NEAT::Config.new.tap do |c|
  c.population_size = 100
  c.inputs = 2
  c.outputs = 1
  c.compatibility_threshold = 3.0
  c.add_connection_rate = 0.2
  c.add_node_rate = 0.05
  c.seed = 2
end

population = NEAT::Population.new(config)

50.times do |generation|
  population.evaluate!(&fitness)
  best = population.best
  outputs = AND_CASES.map { |inputs, _| best.evaluate(inputs).first.round(3) }
  puts "gen=#{generation} fitness=#{best.fitness.round(3)} outputs=#{outputs}"
  break if NEAT::Fitness.solved?(best, AND_CASES)

  population.evolve!
end

population.evaluate!(&fitness)
best = population.best
puts "best fitness=#{best.fitness.round(3)}"
AND_CASES.each do |inputs, target|
  output = best.evaluate(inputs).first
  puts "  #{inputs.map(&:to_i).join(" AND ")} => #{output.round(4)} (target #{target.to_i})"
end

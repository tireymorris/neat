#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../lib/neat"

XOR_CASES = [
  [[1.0, 0.0, 0.0], 0.0],
  [[1.0, 0.0, 1.0], 1.0],
  [[1.0, 1.0, 0.0], 1.0],
  [[1.0, 1.0, 1.0], 0.0]
].freeze

def xor_fitness(genome)
  error = XOR_CASES.sum do |inputs, target|
    (genome.evaluate(inputs).first - target).abs
  end
  (4.0 - error)**2
end

config = NEAT::Config.new.tap do |c|
  c.population_size = 150
  c.inputs = 3
  c.outputs = 1
  c.compatibility_threshold = 3.0
  c.add_connection_rate = 0.3
  c.add_node_rate = 0.1
  c.seed = 1
end

population = NEAT::Population.new(config)

100.times do |generation|
  population.evaluate! { |genome| xor_fitness(genome) }
  best = population.best
  outputs = XOR_CASES.map { |inputs, _| best.evaluate(inputs).first.round(3) }
  puts "gen=#{generation} fitness=#{best.fitness.round(3)} outputs=#{outputs}"
  break if XOR_CASES.all? { |inputs, target| (best.evaluate(inputs).first - target).abs < 0.5 }

  population.evolve!
end

best = population.best
puts "best fitness=#{best.fitness}"
XOR_CASES.each do |inputs, target|
  output = best.evaluate(inputs).first
  puts "  #{inputs[1].to_i} XOR #{inputs[2].to_i} => #{output.round(4)} (target #{target.to_i})"
end

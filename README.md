# neat

Ruby implementation of [NEAT](https://en.wikipedia.org/wiki/Neuroevolution_of_augmenting_topologies) (NeuroEvolution of Augmenting Topologies). Evolve both the structure and weights of neural networks with speciation, crossover aligned by historical innovations, and structural mutation.

## Installation

Add the gem to your Gemfile:

```ruby
gem "neat", path: "."
```

Or install locally:

```bash
bundle install
```

## Quick start

Run the bundled XOR experiment:

```bash
bundle exec ruby examples/xor.rb
```

Or use the CLI:

```bash
bundle exec neat --generations 100 --seed 1
```

## Usage

Configure the algorithm, create a population, and supply a fitness function:

```ruby
require "neat"

config = NEAT::Config.new.tap do |c|
  c.population_size = 150
  c.inputs = 2
  c.outputs = 1
  c.seed = 42
end

cases = [[[0.0, 0.0], 0.0], [[0.0, 1.0], 1.0], [[1.0, 0.0], 1.0], [[1.0, 1.0], 0.0]]
fitness = NEAT::Fitness.evaluator(cases) { |error| -error }

population = NEAT::Population.new(config)
population.run(50, &fitness)

best = population.best
best.evaluate([1.0, 0.0])
```

`NEAT::Fitness.evaluator` builds a proc from labeled input/output cases. Pass a block to transform total absolute error into a score to maximize. Use `NEAT::Fitness.solved?` to check whether outputs are within a tolerance.

Evaluate a single genome directly:

```ruby
genome = population.best
genome.evaluate([1.0, 0.0, 1.0]) # => [output]
```

## Persistence

Save and restore evolved state as JSON:

```ruby
json = population.dump
restored = NEAT::Population.load(json)

genome_json = population.best.dump
genome = NEAT::Genome.load(genome_json, config: config, tracker: population.tracker)
```

Population dumps include config, the shared innovation tracker, generation counter, and all genomes.

## Configuration

`NEAT::Config` controls population size, I/O counts, compatibility threshold, mutation rates, crossover settings, activation default, and optional seed for reproducible runs. See `lib/neat/config.rb` for defaults.

## Development

```bash
bundle exec rspec
```

CI runs the same suite on Ruby 3.3 and 3.4.

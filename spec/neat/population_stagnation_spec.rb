# frozen_string_literal: true

RSpec.describe 'population stagnation' do
  let(:config) do
    NEAT::Config.new.tap do |c|
      c.population_size = 12
      c.inputs = 2
      c.outputs = 1
      c.max_stagnation = 2
      c.compatibility_threshold = 100.0
      c.seed = 11
      c.bias_mutation_rate = 0.0
      c.activation_mutation_rate = 0.0
    end
  end

  it 'tracks staleness across speciation rounds' do
    pop = NEAT::Population.new(config)
    pop.evaluate! { |_g| 1.0 }
    pop.speciate!
    expect(pop.species.first.staleness).to eq(0)

    pop.evaluate! { |_g| 1.0 }
    pop.speciate!
    expect(pop.species.first.staleness).to eq(1)
  end

  it 'evolves for several generations without shrinking population' do
    pop = NEAT::Population.new(config)
    pop.run(5) { |g| g.connection_genes.values.sum { |c| c.weight.abs } }
    expect(pop.genomes.size).to eq(config.population_size)
    expect(pop.generation).to eq(5)
  end

  it 'marks a species stagnant after max_stagnation generations without improvement' do
    species = NEAT::Species.new(NEAT::Genome.new(config, NEAT::InnovationTracker.new))
    genome = NEAT::Genome.new(config, NEAT::InnovationTracker.new)
    genome.fitness = 1.0
    species.add(genome)
    species.update_staleness!
    species.update_staleness!
    species.update_staleness!
    expect(species.stagnant?(config)).to be true
  end
end

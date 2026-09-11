# frozen_string_literal: true

RSpec.describe "population stagnation" do
  let(:config) do
    NEAT::Config.new.tap do |c|
      c.population_size = 12
      c.inputs = 2
      c.outputs = 1
      c.max_stagnation = 2
      c.compatibility_threshold = 100.0 # one species unless we force more
      c.seed = 11
      c.bias_mutation_rate = 0.0
      c.activation_mutation_rate = 0.0
    end
  end

  it "tracks staleness across speciation rounds" do
    pop = NEAT::Population.new(config)
    pop.evaluate! { |_g| 1.0 }
    pop.speciate!
    expect(pop.species.first.staleness).to eq(0)

    pop.evaluate! { |_g| 1.0 }
    pop.speciate!
    expect(pop.species.first.staleness).to eq(1)
  end

  it "keeps at least the best species when others are stagnant" do
    pop = NEAT::Population.new(config)
    # Build two artificial species with fixed fitness
    pop.genomes.each_with_index { |g, i| g.fitness = i.to_f }
    weak = NEAT::Species.new(pop.genomes.first)
    strong = NEAT::Species.new(pop.genomes.last)
    pop.genomes.each { |g| (g.fitness < 6 ? weak : strong).add(g) }
    weak.instance_variable_set(:@staleness, config.max_stagnation)
    weak.instance_variable_set(:@max_fitness, 100.0)
    strong.instance_variable_set(:@staleness, config.max_stagnation)
    strong.instance_variable_set(:@max_fitness, 100.0)
    pop.instance_variable_set(:@species, [weak, strong])

    pop.send(:cull_stagnant_species!)
    expect(pop.species.size).to eq(1)
    expect(pop.species.first.champion.fitness).to eq(pop.genomes.map(&:fitness).max)
  end

  it "evolves for several generations without shrinking population" do
    pop = NEAT::Population.new(config)
    pop.run(5) { |g| g.connection_genes.values.sum { |c| c.weight.abs } }
    expect(pop.genomes.size).to eq(config.population_size)
    expect(pop.generation).to eq(5)
  end
end

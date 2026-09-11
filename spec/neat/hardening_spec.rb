RSpec.describe "neat hardening" do
  let(:config) do
    NEAT::Config.new.tap do |c|
      c.inputs = 2
      c.outputs = 1
      c.initial_connection_prob = 1.0
      c.seed = 99
      c.weight_mutation_rate = 0.0
      c.bias_mutation_rate = 0.0
      c.activation_mutation_rate = 0.0
      c.add_connection_rate = 0.0
      c.add_node_rate = 0.0
      c.toggle_enable_rate = 0.0
    end
  end
  let(:tracker) { NEAT::InnovationTracker.new }

  describe "bias mutation" do
    it "changes non-input node biases" do
      config.bias_mutation_rate = 1.0
      config.bias_perturb_rate = 1.0
      genome = NEAT::Genome.new(config, tracker)
      output = genome.nodes_of_type(:output).first
      original = output.bias
      genome.mutate_biases
      expect(output.bias).not_to eq(original)
    end

    it "does not mutate input biases" do
      config.bias_mutation_rate = 1.0
      genome = NEAT::Genome.new(config, tracker)
      inputs = genome.nodes_of_type(:input)
      before = inputs.map(&:bias)
      genome.mutate_biases
      expect(inputs.map(&:bias)).to eq(before)
    end
  end

  describe "activation mutation" do
    it "can change a non-input activation" do
      config.activation_mutation_rate = 1.0
      config.allowed_activations = %i[sigmoid tanh]
      genome = NEAT::Genome.new(config, tracker)
      output = genome.nodes_of_type(:output).first
      output.activation = :sigmoid
      genome.mutate_activations
      expect(output.activation).to eq(:tanh)
    end
  end

  describe "phenotype cache" do
    it "returns consistent outputs across repeated evaluates" do
      genome = NEAT::Genome.new(config, tracker)
      first = genome.evaluate([1.0, 0.0])
      second = genome.evaluate([1.0, 0.0])
      expect(second).to eq(first)
    end

    it "invalidates when a connection weight changes" do
      genome = NEAT::Genome.new(config, tracker)
      before = genome.evaluate([1.0, 0.0])
      gene = genome.connection_genes.values.first
      gene.weight = gene.weight + 5.0
      genome.invalidate_phenotype!
      after = genome.evaluate([1.0, 0.0])
      expect(after).not_to eq(before)
    end
  end

  describe "feedforward-only connections" do
    it "does not add recurrent connections even when recurrent_allowed is true" do
      config.recurrent_allowed = true
      config.add_connection_rate = 1.0
      genome = NEAT::Genome.new(config, tracker)
      # Only input→output links exist; no higher-layer target for a reverse edge.
      size_before = genome.connection_genes.size
      # With only two layers fully connected, mutate_add_connection may no-op.
      genome.mutate_add_connection
      genome.connection_genes.each_value do |c|
        src = genome.node_genes[c.in_node]
        dst = genome.node_genes[c.out_node]
        expect(src.layer).to be < dst.layer
      end
      expect(genome.connection_genes.size).to be >= size_before
    end
  end

  describe "species stagnation" do
    it "increments staleness when champion fitness does not improve" do
      species = NEAT::Species.new(NEAT::Genome.new(config, tracker))
      g = NEAT::Genome.new(config, tracker)
      g.fitness = 1.0
      species.add(g)
      species.update_staleness!
      expect(species.staleness).to eq(0)
      expect(species.max_fitness).to eq(1.0)

      g.fitness = 1.0
      species.update_staleness!
      expect(species.staleness).to eq(1)
    end

    it "resets staleness when champion fitness improves" do
      species = NEAT::Species.new(NEAT::Genome.new(config, tracker))
      g = NEAT::Genome.new(config, tracker)
      g.fitness = 1.0
      species.add(g)
      species.update_staleness!
      species.update_staleness!
      g.fitness = 2.0
      species.update_staleness!
      expect(species.staleness).to eq(0)
      expect(species.max_fitness).to eq(2.0)
    end

    it "culls stagnant species but protects the global best" do
      config.population_size = 4
      config.max_stagnation = 1
      config.compatibility_threshold = 0.0
      pop = NEAT::Population.new(config)

      pop.genomes.each_with_index { |g, i| g.fitness = i.to_f }
      # Force distinct species by making distance always exceed threshold already set to 0
      # With threshold 0, only identical distance 0 matches — each genome becomes its own species
      # if representatives differ. Dup genomes may still be distance 0.
      pop.instance_variable_set(:@species, [])
      pop.genomes.each do |genome|
        species = NEAT::Species.new(genome)
        species.add(genome)
        species.instance_variable_set(:@max_fitness, genome.fitness + 10.0) # already "stale" path
        species.instance_variable_set(:@staleness, config.max_stagnation)
        pop.species << species
      end

      best = pop.best
      pop.send(:cull_stagnant_species!)
      expect(pop.species.size).to eq(1)
      expect(pop.species.first.champion).to eq(best)
    end
  end

  describe "config defaults" do
    it "includes stagnation and bias/activation knobs" do
      c = NEAT::Config.new
      expect(c.max_stagnation).to eq(15)
      expect(c.bias_mutation_rate).to eq(0.7)
      expect(c.activation_mutation_rate).to eq(0.0)
      expect(c.allowed_activations).to eq(%i[sigmoid tanh relu])
    end
  end
end

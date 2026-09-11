RSpec.describe "serialization" do
  let(:config) do
    NEAT::Config.new.tap do |c|
      c.population_size = 5
      c.inputs = 2
      c.outputs = 1
      c.activation_default = :sigmoid
      c.seed = 7
    end
  end

  describe NEAT::Config do
    it "round-trips through a hash" do
      restored = described_class.from_h(config.to_h)
      expect(restored.to_h).to eq(config.to_h)
    end
  end

  describe NEAT::InnovationTracker do
    it "round-trips through a hash" do
      tracker = described_class.new(next_node_id: 3)
      tracker.new_connection(0, 2)
      tracker.new_node_split(0, 2)

      restored = described_class.from_h(tracker.to_h)
      expect(restored.to_h).to eq(tracker.to_h)
    end
  end

  describe NEAT::Genome do
    it "round-trips through JSON" do
      tracker = NEAT::InnovationTracker.new
      genome = NEAT::Genome.new(config, tracker)
      genome.mutate
      genome.fitness = 12.5

      restored = NEAT::Genome.load(genome.dump, config: config, tracker: tracker)
      expect(restored.to_h).to eq(genome.to_h)
    end
  end

  describe NEAT::Population do
    it "round-trips through JSON" do
      population = NEAT::Population.new(config)
      population.evaluate! { |_genome| 3.0 }
      population.evolve!

      restored = NEAT::Population.load(population.dump)
      expect(restored.generation).to eq(population.generation)
      expect(restored.genomes.map(&:to_h)).to eq(population.genomes.map(&:to_h))
      expect(restored.config.to_h).to eq(population.config.to_h)
    end
  end
end

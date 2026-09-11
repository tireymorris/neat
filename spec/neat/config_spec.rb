RSpec.describe NEAT::Config do
  subject(:config) { described_class.new }

  describe "defaults" do
    it "has a default population size" do
      expect(config.population_size).to eq(150)
    end

    it "has default NEAT coefficients" do
      expect(config.excess_coefficient).to eq(1.0)
      expect(config.disjoint_coefficient).to eq(1.0)
      expect(config.weight_coefficient).to eq(0.4)
    end

    it "has default structural mutation rates" do
      expect(config.add_connection_rate).to eq(0.05)
      expect(config.add_node_rate).to eq(0.03)
    end

    it "has a compatibility threshold" do
      expect(config.compatibility_threshold).to eq(3.0)
    end

    it "has default reproduction settings" do
      expect(config.survival_threshold).to eq(0.2)
      expect(config.crossover_rate).to eq(0.75)
      expect(config.interspecies_mate_rate).to eq(0.001)
    end

    it "provides a deterministic random number generator when seeded" do
      config.seed = 123
      first = config.rng.rand
      config.seed = 123
      expect(config.rng.rand).to eq(first)
    end

    it "defaults max_stagnation to 15" do
      expect(config.max_stagnation).to eq(15)
    end

    it "defaults activation mutation off" do
      expect(config.activation_mutation_rate).to eq(0.0)
    end

    it "includes hardening keys in to_h" do
      expect(config.to_h).to include(
        :max_stagnation,
        :bias_mutation_rate,
        :bias_perturb_rate,
        :activation_mutation_rate,
        :allowed_activations
      )
    end
  end

  describe "customization" do
    it "allows population size to be changed" do
      config.population_size = 50
      expect(config.population_size).to eq(50)
    end
  end
end

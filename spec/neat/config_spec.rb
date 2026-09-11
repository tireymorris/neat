# frozen_string_literal: true

RSpec.describe NEAT::Config do
  subject { described_class.new }

  describe 'defaults' do
    it 'has a default population size' do
      expect(subject.population_size).to eq(150)
    end

    it 'has default NEAT coefficients' do
      expect(subject.excess_coefficient).to eq(1.0)
      expect(subject.disjoint_coefficient).to eq(1.0)
      expect(subject.weight_coefficient).to eq(0.4)
    end

    it 'has default structural mutation rates' do
      expect(subject.add_connection_rate).to eq(0.05)
      expect(subject.add_node_rate).to eq(0.03)
    end

    it 'has a compatibility threshold' do
      expect(subject.compatibility_threshold).to eq(3.0)
    end

    it 'has default reproduction settings' do
      expect(subject.survival_threshold).to eq(0.2)
      expect(subject.crossover_rate).to eq(0.75)
      expect(subject.interspecies_mate_rate).to eq(0.001)
    end

    it 'provides a deterministic random number generator when seeded' do
      subject.seed = 123
      first = subject.rng.rand
      subject.seed = 123
      expect(subject.rng.rand).to eq(first)
    end

    it 'defaults max_stagnation to 15' do
      expect(subject.max_stagnation).to eq(15)
    end

    it 'defaults activation mutation off' do
      expect(subject.activation_mutation_rate).to eq(0.0)
    end

    it 'includes hardening keys in to_h' do
      expect(subject.to_h).to include(
        :max_stagnation,
        :bias_mutation_rate,
        :bias_perturb_rate,
        :activation_mutation_rate,
        :allowed_activations
      )
    end
  end

  describe 'customization' do
    it 'allows population size to be changed' do
      subject.population_size = 50
      expect(subject.population_size).to eq(50)
    end
  end
end

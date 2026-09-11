RSpec.describe NEAT::Fitness do
  let(:cases) { [[[0.0, 0.0], 0.0], [[1.0, 0.0], 1.0]] }

  describe ".evaluator" do
    it "scores a genome from labeled cases" do
      config = NEAT::Config.new.tap { |c| c.inputs = 2; c.outputs = 1; c.seed = 1 }
      genome = NEAT::Genome.new(config, NEAT::InnovationTracker.new)

      fitness = described_class.evaluator(cases) { |error| -error }
      expect(fitness.call(genome)).to be <= 0.0
    end

    it "applies the given transform block" do
      config = NEAT::Config.new.tap { |c| c.inputs = 2; c.outputs = 1; c.seed = 1 }
      genome = NEAT::Genome.new(config, NEAT::InnovationTracker.new)

      fitness = described_class.evaluator(cases) { |error| (2.0 - error)**2 }
      expect(fitness.call(genome)).to be > 0.0
    end
  end

  describe ".solved?" do
    it "returns true when every output is within tolerance" do
      config = NEAT::Config.new.tap { |c| c.inputs = 2; c.outputs = 1; c.seed = 1 }
      genome = NEAT::Genome.new(config, NEAT::InnovationTracker.new)
      allow(genome).to receive(:evaluate).and_return([0.0], [1.0])

      expect(described_class.solved?(genome, cases)).to be true
    end

    it "returns false when any output is outside tolerance" do
      config = NEAT::Config.new.tap { |c| c.inputs = 2; c.outputs = 1; c.seed = 1 }
      genome = NEAT::Genome.new(config, NEAT::InnovationTracker.new)
      allow(genome).to receive(:evaluate).and_return([0.0], [0.2])

      expect(described_class.solved?(genome, cases)).to be false
    end
  end
end

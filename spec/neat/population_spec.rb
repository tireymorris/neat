RSpec.describe NEAT::Population do
  let(:config) do
    NEAT::Config.new.tap do |c|
      c.population_size = 20
      c.inputs = 2
      c.outputs = 1
      c.compatibility_threshold = 3.0
      c.survival_threshold = 0.5
      c.crossover_rate = 0.75
      c.seed = 42
    end
  end

  subject { described_class.new(config) }

  describe "initialization" do
    it "creates a population of the configured size" do
      expect(subject.genomes.size).to eq(20)
    end

    it "shares one innovation tracker across genomes" do
      trackers = subject.genomes.map(&:tracker).uniq
      expect(trackers.size).to eq(1)
    end

    it "starts at generation zero" do
      expect(subject.generation).to eq(0)
    end
  end

  describe "#evaluate!" do
    it "assigns fitness from the given block" do
      subject.evaluate! { |_genome| 7.5 }
      expect(subject.genomes.map(&:fitness)).to all(eq(7.5))
    end
  end

  describe "#best" do
    it "returns the genome with the highest fitness" do
      subject.genomes.each_with_index { |g, i| g.fitness = i.to_f }
      expect(subject.best).to eq(subject.genomes.last)
    end
  end

  describe "#speciate!" do
    it "places every genome into a species" do
      subject.speciate!
      expect(subject.species.sum { |s| s.members.size }).to eq(subject.genomes.size)
      expect(subject.species).not_to be_empty
    end

    it "puts compatible genomes in the same species" do
      subject.speciate!
      subject.species.each do |species|
        species.members.each do |member|
          expect(species.compatible?(member, config)).to be true
        end
      end
    end
  end

  describe "#evolve!" do
    before do
      subject.evaluate! { |genome| genome.connection_genes.values.sum { |c| c.weight.abs } }
    end

    it "advances the generation counter" do
      expect { subject.evolve! }.to change { subject.generation }.by(1)
    end

    it "keeps the population size constant" do
      subject.evolve!
      expect(subject.genomes.size).to eq(config.population_size)
    end

    it "preserves the previous champion unchanged" do
      champion = subject.best.dup
      subject.evolve!
      elites = subject.genomes.select do |g|
        g.connection_genes.keys == champion.connection_genes.keys &&
          g.connection_genes.values.map(&:weight) == champion.connection_genes.values.map(&:weight)
      end
      expect(elites).not_to be_empty
    end
  end

  describe "#run" do
    it "evaluates and evolves for the given number of generations" do
      subject.run(3) { |_genome| 1.0 }
      expect(subject.generation).to eq(3)
      expect(subject.genomes.map(&:fitness)).to all(eq(1.0))
    end
  end
end

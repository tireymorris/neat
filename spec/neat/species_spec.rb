RSpec.describe NEAT::Species do
  let(:config) do
    NEAT::Config.new.tap do |c|
      c.inputs = 2
      c.outputs = 1
      c.compatibility_threshold = 3.0
      c.survival_threshold = 0.5
      c.seed = 1
    end
  end
  let(:tracker) { NEAT::InnovationTracker.new }
  let(:representative) { NEAT::Genome.new(config, tracker) }

  subject { described_class.new(representative) }

  describe "#add" do
    it "adds a genome to the species" do
      genome = representative.dup
      subject.add(genome)
      expect(subject.members).to include(genome)
    end
  end

  describe "#compatible?" do
    it "is true when distance is within the threshold" do
      expect(subject.compatible?(representative.dup, config)).to be true
    end

    it "is false when distance exceeds the threshold" do
      distant = representative.dup
      5.times { distant.mutate_add_node }
      expect(subject.compatible?(distant, config)).to be false
    end
  end

  describe "#adjusted_fitnesses" do
    it "divides each member fitness by the species size" do
      a = representative.dup
      a.fitness = 10.0
      b = representative.dup
      b.fitness = 6.0
      subject.add(a)
      subject.add(b)

      expect(subject.adjusted_fitnesses).to eq([5.0, 3.0])
    end
  end

  describe "#total_adjusted_fitness" do
    it "sums adjusted fitnesses" do
      a = representative.dup
      a.fitness = 10.0
      b = representative.dup
      b.fitness = 6.0
      subject.add(a)
      subject.add(b)

      expect(subject.total_adjusted_fitness).to eq(8.0)
    end
  end

  describe "#champion" do
    it "returns the member with the highest fitness" do
      weak = representative.dup
      weak.fitness = 1.0
      strong = representative.dup
      strong.fitness = 9.0
      subject.add(weak)
      subject.add(strong)

      expect(subject.champion).to eq(strong)
    end
  end

  describe "#survivors" do
    it "keeps the top fraction of members by fitness" do
      low = representative.dup
      low.fitness = 1.0
      mid = representative.dup
      mid.fitness = 5.0
      high = representative.dup
      high.fitness = 9.0
      subject.add(low)
      subject.add(mid)
      subject.add(high)

      expect(subject.survivors(config)).to eq([high, mid])
    end

    it "always keeps at least one survivor" do
      lone = representative.dup
      lone.fitness = 1.0
      subject.add(lone)

      expect(subject.survivors(config)).to eq([lone])
    end
  end

  describe "#pick_parent" do
    it "selects a survivor with fitness-proportional probability" do
      weak = representative.dup
      weak.fitness = 0.0
      strong = representative.dup
      strong.fitness = 100.0
      subject.add(weak)
      subject.add(strong)

      picks = 20.times.map { subject.pick_parent(config) }
      expect(picks).to include(strong)
    end
  end
end

RSpec.describe NEAT::Genome do
  let(:config) do
    NEAT::Config.new.tap do |c|
      c.inputs = 2
      c.outputs = 1
      c.initial_connection_prob = 1.0
      c.activation_default = :sigmoid
      c.seed = 42
    end
  end
  let(:tracker) { NEAT::InnovationTracker.new }

  describe "initialization" do
    it "creates input and output nodes" do
      genome = described_class.new(config, tracker)
      expect(genome.node_genes.values.count(&:input?)).to eq(2)
      expect(genome.node_genes.values.count(&:output?)).to eq(1)
    end

    it "connects every input to every output when initial_connection_prob is 1.0" do
      genome = described_class.new(config, tracker)
      expect(genome.connection_genes.size).to eq(2)
    end

    it "does not create hidden nodes by default" do
      genome = described_class.new(config, tracker)
      expect(genome.node_genes.values.none?(&:hidden?)).to be true
    end
  end

  describe "#evaluate" do
    it "returns output values for the given inputs" do
      genome = described_class.new(config, tracker)
      outputs = genome.evaluate([1.0, 0.0])
      expect(outputs).to be_a(Array)
      expect(outputs.size).to eq(1)
      expect(outputs.first).to be_a(Float)
    end

    it "raises when the network contains a cycle" do
      genome = described_class.new(config, tracker)
      # Manually create a cycle by adding a connection from output back to input.
      # This requires bypassing the normal feedforward mutation restrictions.
      innov = tracker.new_connection(config.inputs, 0)
      genome.add_connection(NEAT::ConnectionGene.new(config.inputs, 0, weight: 1.0, innovation: innov))
      expect { genome.evaluate([1.0, 0.0]) }.to raise_error(NEAT::CyclicNetworkError)
    end
  end

  describe "#dup" do
    it "produces an independent copy with the same genes" do
      genome = described_class.new(config, tracker)
      copy = genome.dup
      expect(copy.node_genes.size).to eq(genome.node_genes.size)
      expect(copy.connection_genes.size).to eq(genome.connection_genes.size)
      expect(copy.connection_genes).not_to equal(genome.connection_genes)
    end
  end

  describe "mutations" do
    before do
      config.weight_mutation_rate = 1.0
      config.weight_perturb_rate = 1.0
      config.add_connection_rate = 0.0
      config.add_node_rate = 0.0
      config.toggle_enable_rate = 0.0
    end

    describe "#mutate_weights" do
      it "changes connection weights" do
        genome = described_class.new(config, tracker)
        original = genome.connection_genes.values.first.weight
        genome.mutate_weights
        expect(genome.connection_genes.values.first.weight).not_to eq(original)
      end
    end

    describe "#mutate_add_connection" do
      it "adds a new feedforward connection" do
        # Add a hidden node manually so there is a place for a new connection.
        genome = described_class.new(config, tracker)
        node_innov, in_innov, out_innov = tracker.new_node_split(0, config.inputs)
        genome.add_node(NEAT::NodeGene.new(node_innov, :hidden, layer: 0.5))
        genome.add_connection(NEAT::ConnectionGene.new(0, node_innov, weight: 1.0, innovation: in_innov))
        genome.add_connection(NEAT::ConnectionGene.new(node_innov, config.inputs, weight: 1.0, innovation: out_innov))

        expect { genome.mutate_add_connection }.to change { genome.connection_genes.size }.by(1)
      end
    end

    describe "#mutate_add_node" do
      it "splits an enabled connection into two connections" do
        genome = described_class.new(config, tracker)
        expect { genome.mutate_add_node }.to change { genome.connection_genes.size }.by(1)
        expect(genome.node_genes.values.count(&:hidden?)).to eq(1)
      end
    end
  end

  describe "#compatibility_distance" do
    it "is zero between identical genomes" do
      genome = described_class.new(config, tracker)
      other = genome.dup
      expect(genome.compatibility_distance(other)).to eq(0.0)
    end

    it "increases when genomes diverge structurally" do
      genome = described_class.new(config, tracker)
      other = genome.dup
      other.mutate_add_node
      expect(genome.compatibility_distance(other)).to be > 0.0
    end
  end

  describe "#crossover" do
    it "produces a child containing genes from the fitter parent" do
      parent1 = described_class.new(config, tracker)
      parent1.fitness = 10.0
      parent2 = described_class.new(config, tracker)
      parent2.fitness = 5.0
      parent2.mutate_add_node

      child = parent1.crossover(parent2)
      expect(child.node_genes.size).to be >= parent1.node_genes.size
      expect(child.connection_genes.size).to be >= parent1.connection_genes.size
    end
  end
end

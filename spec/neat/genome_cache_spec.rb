# frozen_string_literal: true

RSpec.describe "genome phenotype cache" do
  let(:config) do
    NEAT::Config.new.tap do |c|
      c.inputs = 2
      c.outputs = 1
      c.seed = 4
      c.bias_mutation_rate = 0.0
      c.activation_mutation_rate = 0.0
      c.weight_mutation_rate = 0.0
      c.add_connection_rate = 0.0
      c.add_node_rate = 0.0
      c.toggle_enable_rate = 0.0
    end
  end
  let(:tracker) { NEAT::InnovationTracker.new }
  let(:genome) { NEAT::Genome.new(config, tracker) }

  it "caches topological order between evaluates" do
    genome.evaluate([0.2, 0.8])
    order_object_id = genome.instance_variable_get(:@phenotype_order).object_id
    genome.evaluate([0.3, 0.7])
    expect(genome.instance_variable_get(:@phenotype_order).object_id).to eq(order_object_id)
  end

  it "rebuilds cache after structural mutation" do
    genome.evaluate([1.0, 0.0])
    before = genome.instance_variable_get(:@phenotype_order)
    genome.mutate_add_node
    expect(genome.instance_variable_get(:@phenotype_order)).to be_nil
    genome.evaluate([1.0, 0.0])
    expect(genome.instance_variable_get(:@phenotype_order)).not_to eq(before)
  end

  it "round-trips config keys for new hardening options" do
    config.max_stagnation = 9
    config.bias_mutation_rate = 0.55
    config.allowed_activations = %i[tanh relu]
    restored = NEAT::Config.from_h(config.to_h)
    expect(restored.max_stagnation).to eq(9)
    expect(restored.bias_mutation_rate).to eq(0.55)
    expect(restored.allowed_activations).to eq(%i[tanh relu])
  end
end

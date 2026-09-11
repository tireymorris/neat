# frozen_string_literal: true

RSpec.describe "NEAT::Genome.reencode_from_h" do
  let(:config) do
    NEAT::Config.new.tap do |c|
      c.inputs = 2
      c.outputs = 1
      c.population_size = 4
      c.seed = 7
      c.initial_connection_prob = 1.0
    end
  end

  it "rebuilds topology on a shared tracker with fresh innovations" do
    source_tracker = NEAT::InnovationTracker.new
    source = NEAT::Genome.new(config, source_tracker)
    source.mutate_add_node if source.connection_genes.any?

    dest_tracker = NEAT::InnovationTracker.new
    dest_tracker.reserve_node_ids(config.inputs + config.outputs)
    reencoded = NEAT::Genome.reencode_from_h(source.to_h, config: config, tracker: dest_tracker)

    expect(reencoded.node_genes.size).to eq(source.node_genes.size)
    expect(reencoded.connection_genes.size).to eq(source.connection_genes.size)
    expect(reencoded.nodes_of_type(:hidden).size).to eq(source.nodes_of_type(:hidden).size)
    expect(reencoded.evaluate([0.5, -0.25])).to be_a(Array)
  end
end

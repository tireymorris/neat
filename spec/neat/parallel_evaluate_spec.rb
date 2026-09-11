# frozen_string_literal: true

RSpec.describe 'parallel evaluate' do
  let(:config) do
    NEAT::Config.new.tap do |c|
      c.population_size = 8
      c.inputs = 2
      c.outputs = 1
      c.seed = 1
      c.evaluation_workers = 2
    end
  end

  it 'assigns fitness with multiple workers' do
    pop = NEAT::Population.new(config)
    pop.evaluate! { |genome| genome.connection_genes.size.to_f }
    expect(pop.genomes.map(&:fitness)).to all(be >= 0.0)
    expect(pop.genomes.map(&:fitness).uniq.size).to be >= 1
  end
end

RSpec.describe "XOR experiment" do
  XOR_CASES = [
    [[1.0, 0.0, 0.0], 0.0],
    [[1.0, 0.0, 1.0], 1.0],
    [[1.0, 1.0, 0.0], 1.0],
    [[1.0, 1.0, 1.0], 0.0]
  ].freeze

  def xor_fitness(genome)
    NEAT::Fitness.evaluator(XOR_CASES) { |error| (4.0 - error)**2 }.call(genome)
  end

  def solved?(genome)
    NEAT::Fitness.solved?(genome, XOR_CASES)
  end

  it "evolves a network that solves XOR" do
    config = NEAT::Config.new.tap do |c|
      c.population_size = 150
      c.inputs = 3
      c.outputs = 1
      c.compatibility_threshold = 3.0
      c.add_connection_rate = 0.3
      c.add_node_rate = 0.1
      c.seed = 1
    end

    population = NEAT::Population.new(config)
    population.run(100) { |genome| xor_fitness(genome) }

    expect(solved?(population.best)).to be true
  end
end

RSpec.describe "XOR experiment" do
  XOR_CASES = [
    [[1.0, 0.0, 0.0], 0.0],
    [[1.0, 0.0, 1.0], 1.0],
    [[1.0, 1.0, 0.0], 1.0],
    [[1.0, 1.0, 1.0], 0.0]
  ].freeze

  def xor_fitness(genome)
    error = XOR_CASES.sum do |inputs, target|
      (genome.evaluate(inputs).first - target).abs
    end
    (4.0 - error)**2
  end

  def solved?(genome)
    XOR_CASES.all? do |inputs, target|
      output = genome.evaluate(inputs).first
      (output - target).abs < 0.5
    end
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

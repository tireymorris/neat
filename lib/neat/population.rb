require "json"

module NEAT
  class Population
    attr_reader :config, :tracker, :genomes, :species, :generation

    def initialize(config, state: nil)
      @config = config
      if state
        @tracker = state[:tracker]
        @genomes = state[:genomes]
        @generation = state[:generation]
        @species = []
      else
        @tracker = InnovationTracker.new(next_node_id: config.inputs + config.outputs)
        @genomes = Array.new(config.population_size) { Genome.new(config, @tracker) }
        @species = []
        @generation = 0
      end
    end

    def evaluate!
      @genomes.each { |genome| genome.fitness = yield(genome) }
    end

    def best
      @genomes.max_by(&:fitness)
    end

    def speciate!
      prepare_species_shells
      @genomes.each { |genome| assign_species(genome) }
      @species.reject! { |species| species.members.empty? }
    end

    def evolve!
      speciate!
      offspring = reproduce
      @genomes = offspring
      @generation += 1
    end

    def run(generations)
      generations.times do
        evaluate! { |genome| yield(genome) }
        evolve!
      end
      evaluate! { |genome| yield(genome) }
    end

    def to_h
      {
        config: @config.to_h,
        tracker: @tracker.to_h,
        generation: @generation,
        genomes: @genomes.map(&:to_h)
      }
    end

    def self.from_h(hash, config: nil)
      data = hash.transform_keys(&:to_sym)
      config ||= Config.from_h(data.fetch(:config))
      tracker = InnovationTracker.from_h(data.fetch(:tracker))
      genomes = data.fetch(:genomes).map { |genome| Genome.from_h(genome, config: config, tracker: tracker) }
      new(config, state: { tracker: tracker, genomes: genomes, generation: data.fetch(:generation) })
    end

    def dump(io = nil)
      json = JSON.pretty_generate(to_h)
      io ? io.write(json) : json
    end

    def self.load(source, config: nil)
      hash = source.is_a?(String) ? JSON.parse(source) : source
      from_h(hash, config: config)
    end

    private

    def prepare_species_shells
      return if @species.empty?

      @species.each do |species|
        next if species.members.empty?

        species.representative = species.members.sample(random: @config.rng)
        species.members.clear
      end
    end

    def assign_species(genome)
      match = @species.find { |species| species.compatible?(genome, @config) }
      if match
        match.add(genome)
        return
      end

      species = Species.new(genome)
      species.add(genome)
      @species << species
    end

    def reproduce
      total_adj = @species.sum(&:total_adjusted_fitness)
      total_adj = 1.0 if total_adj <= 0.0

      quotas = @species.map do |species|
        ((species.total_adjusted_fitness / total_adj) * @config.population_size).round
      end
      adjust_quotas!(quotas)

      offspring = []
      @species.each_with_index do |species, index|
        count = quotas[index]
        next if count <= 0

        offspring << species.champion.dup
        (count - 1).times { offspring << breed(species) }
      end

      while offspring.size < @config.population_size
        offspring << breed(@species.max_by(&:total_adjusted_fitness))
      end

      offspring.first(@config.population_size)
    end

    def adjust_quotas!(quotas)
      return if quotas.empty?

      quotas.map! { |q| [q, 0].max }
      quotas[0] = 1 if quotas.all?(&:zero?)

      delta = @config.population_size - quotas.sum
      cursor = 0
      while delta != 0
        index = cursor % quotas.size
        if delta > 0
          quotas[index] += 1
          delta -= 1
        elsif quotas[index] > 0
          quotas[index] -= 1
          delta += 1
        end
        cursor += 1
      end
    end

    def breed(species)
      parent1 = species.pick_parent(@config)
      child =
        if @config.rng.rand < @config.crossover_rate && species.members.size > 1
          parent2 = mate_for(species)
          parent1.crossover(parent2)
        else
          parent1.dup
        end
      child.mutate
      child.fitness = -Float::INFINITY
      child
    end

    def mate_for(species)
      if @config.rng.rand < @config.interspecies_mate_rate && @species.size > 1
        other = (@species - [species]).sample(random: @config.rng)
        return other.pick_parent(@config)
      end

      species.pick_parent(@config)
    end
  end
end

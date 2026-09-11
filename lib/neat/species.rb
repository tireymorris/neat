module NEAT
  class Species
    attr_accessor :representative
    attr_reader :members

    def initialize(representative)
      @representative = representative
      @members = []
    end

    def add(genome)
      @members << genome
    end

    def compatible?(genome, config)
      @representative.compatibility_distance(genome) < config.compatibility_threshold
    end

    def adjusted_fitnesses
      size = [@members.size, 1].max.to_f
      @members.map { |m| m.fitness / size }
    end

    def total_adjusted_fitness
      adjusted_fitnesses.sum
    end

    def champion
      @members.max_by(&:fitness)
    end

    def survivors(config)
      ranked = @members.sort_by { |m| -m.fitness }
      count = [(ranked.size * config.survival_threshold).ceil, 1].max
      ranked.first(count)
    end

    def pick_parent(config)
      pool = survivors(config)
      total = pool.sum { |m| [m.fitness, 0.0].max }
      return pool.sample(random: config.rng) if total <= 0.0

      target = config.rng.rand * total
      cumulative = 0.0
      pool.each do |member|
        cumulative += [member.fitness, 0.0].max
        return member if cumulative >= target
      end
      pool.last
    end
  end
end

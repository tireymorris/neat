module NEAT
  class Config
    attr_accessor :population_size,
                  :excess_coefficient,
                  :disjoint_coefficient,
                  :weight_coefficient,
                  :add_connection_rate,
                  :add_node_rate,
                  :compatibility_threshold,
                  :seed

    def initialize
      @population_size = 150
      @excess_coefficient = 1.0
      @disjoint_coefficient = 1.0
      @weight_coefficient = 0.4
      @add_connection_rate = 0.05
      @add_node_rate = 0.03
      @compatibility_threshold = 3.0
      @seed = nil
    end

    def rng
      @rng ||= @seed ? Random.new(@seed) : Random.new
    end
  end
end

module NEAT
  class Config
    attr_accessor :population_size,
                  :inputs,
                  :outputs,
                  :excess_coefficient,
                  :disjoint_coefficient,
                  :weight_coefficient,
                  :add_connection_rate,
                  :add_node_rate,
                  :toggle_enable_rate,
                  :weight_mutation_rate,
                  :weight_perturb_rate,
                  :compatibility_threshold,
                  :initial_connection_prob,
                  :activation_default,
                  :recurrent_allowed,
                  :reenable_rate,
                  :survival_threshold,
                  :crossover_rate,
                  :interspecies_mate_rate
    attr_reader :seed

    def initialize
      @population_size = 150
      @inputs = 0
      @outputs = 0
      @excess_coefficient = 1.0
      @disjoint_coefficient = 1.0
      @weight_coefficient = 0.4
      @add_connection_rate = 0.05
      @add_node_rate = 0.03
      @toggle_enable_rate = 0.01
      @weight_mutation_rate = 0.8
      @weight_perturb_rate = 0.9
      @compatibility_threshold = 3.0
      @initial_connection_prob = 1.0
      @activation_default = :sigmoid
      @recurrent_allowed = false
      @reenable_rate = 0.25
      @survival_threshold = 0.2
      @crossover_rate = 0.75
      @interspecies_mate_rate = 0.001
      @seed = nil
    end

    def seed=(value)
      @seed = value
      @rng = nil
    end

    def rng
      @rng ||= @seed ? Random.new(@seed) : Random.new
    end
  end
end

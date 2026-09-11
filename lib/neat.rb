require_relative "neat/config"
require_relative "neat/activations"
require_relative "neat/genes"
require_relative "neat/innovation_tracker"
require_relative "neat/genome"

module NEAT
  class Error < StandardError; end
  class CyclicNetworkError < Error; end
end

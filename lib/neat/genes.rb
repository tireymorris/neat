module NEAT
  class NodeGene
    attr_accessor :id, :type, :bias, :activation, :layer

    def initialize(id, type, bias: 0.0, activation: :sigmoid, layer: nil)
      @id = id
      @type = type
      @bias = bias
      @activation = activation
      @layer = layer
    end

    def input?
      @type == :input
    end

    def hidden?
      @type == :hidden
    end

    def output?
      @type == :output
    end

    def dup
      NodeGene.new(@id, @type, bias: @bias, activation: @activation, layer: @layer)
    end

    def to_h
      { id: @id, type: @type, bias: @bias, activation: @activation, layer: @layer }
    end

    def self.from_h(hash)
      data = hash.transform_keys(&:to_sym)
      new(
        data[:id],
        data[:type].to_sym,
        bias: data[:bias],
        activation: data[:activation].to_sym,
        layer: data[:layer]
      )
    end
  end

  class ConnectionGene
    attr_accessor :in_node, :out_node, :weight, :enabled, :innovation

    def initialize(in_node, out_node, weight:, enabled: true, innovation:)
      @in_node = in_node
      @out_node = out_node
      @weight = weight
      @enabled = enabled
      @innovation = innovation
    end

    def dup
      ConnectionGene.new(@in_node, @out_node, weight: @weight, enabled: @enabled, innovation: @innovation)
    end

    def to_h
      { in_node: @in_node, out_node: @out_node, weight: @weight, enabled: @enabled, innovation: @innovation }
    end

    def self.from_h(hash)
      data = hash.transform_keys(&:to_sym)
      new(
        data[:in_node],
        data[:out_node],
        weight: data[:weight],
        enabled: data[:enabled],
        innovation: data[:innovation]
      )
    end
  end
end

module NEAT
  class Genome
    attr_accessor :fitness, :config, :tracker, :node_genes, :connection_genes

    def initialize(config, tracker, build_initial: true)
      @config = config
      @tracker = tracker
      @node_genes = {}
      @connection_genes = {}
      @fitness = -Float::INFINITY

      if build_initial
        build_base_nodes
        build_initial_connections
      end
    end

    def build_base_nodes
      @config.inputs.times do |i|
        add_node(NodeGene.new(i, :input, activation: :linear, layer: 0))
      end

      @config.outputs.times do |o|
        id = @config.inputs + o
        add_node(NodeGene.new(id, :output, activation: @config.activation_default, layer: 1))
      end
    end

    def build_initial_connections
      return unless @config.initial_connection_prob > 0

      input_nodes = nodes_of_type(:input)
      output_nodes = nodes_of_type(:output)

      output_nodes.each do |out|
        input_nodes.each do |inp|
          next unless @config.rng.rand < @config.initial_connection_prob
          innov = @tracker.new_connection(inp.id, out.id)
          add_connection(ConnectionGene.new(inp.id, out.id, weight: random_weight, innovation: innov))
        end
      end
    end

    def add_node(gene)
      @node_genes[gene.id] = gene
    end

    def add_connection(gene)
      return false unless @node_genes.key?(gene.in_node) && @node_genes.key?(gene.out_node)
      @connection_genes[gene.innovation] = gene
      true
    end

    def random_weight
      @config.rng.rand * 4.0 - 2.0
    end

    def mutate
      mutate_weights
      mutate_add_connection if @config.rng.rand < @config.add_connection_rate
      mutate_add_node if @config.rng.rand < @config.add_node_rate
      mutate_toggle_enable if @config.rng.rand < @config.toggle_enable_rate
    end

    def mutate_weights
      @connection_genes.each do |_, gene|
        next unless @config.rng.rand < @config.weight_mutation_rate
        if @config.rng.rand < @config.weight_perturb_rate
          gene.weight += @config.rng.rand * 2.0 - 1.0
        else
          gene.weight = random_weight
        end
        gene.weight = [[gene.weight, -8.0].max, 8.0].min
      end
    end

    def mutate_add_connection
      candidates = []
      nodes = @node_genes.values

      nodes.each do |src|
        nodes.each do |dst|
          next if src.id == dst.id
          if @config.recurrent_allowed
            candidates << [src, dst] unless connection_between?(src.id, dst.id)
          elsif src.layer && dst.layer && src.layer < dst.layer && !connection_between?(src.id, dst.id)
            candidates << [src, dst]
          end
        end
      end

      return if candidates.empty?
      src, dst = candidates.sample(random: @config.rng)
      innov = @tracker.new_connection(src.id, dst.id)
      add_connection(ConnectionGene.new(src.id, dst.id, weight: random_weight, innovation: innov))
    end

    def connection_between?(a, b)
      @connection_genes.values.any? { |g| g.in_node == a && g.out_node == b }
    end

    def mutate_add_node
      enabled = @connection_genes.values.select(&:enabled)
      return if enabled.empty?

      conn = enabled.sample(random: @config.rng)
      conn.enabled = false

      node_id, in_innov, out_innov = @tracker.new_node_split(conn.in_node, conn.out_node)
      src_layer = @node_genes[conn.in_node].layer
      dst_layer = @node_genes[conn.out_node].layer
      layer = (src_layer && dst_layer) ? (src_layer + dst_layer) / 2.0 : nil

      add_node(NodeGene.new(node_id, :hidden, activation: @config.activation_default, layer: layer))
      add_connection(ConnectionGene.new(conn.in_node, node_id, weight: 1.0, innovation: in_innov))
      add_connection(ConnectionGene.new(node_id, conn.out_node, weight: conn.weight, innovation: out_innov))
    end

    def mutate_toggle_enable
      return if @connection_genes.empty?
      gene = @connection_genes.values.sample(random: @config.rng)
      gene.enabled = !gene.enabled
    end

    def evaluate(inputs)
      order = topological_order
      values = {}

      input_ids = nodes_of_type(:input).map(&:id)
      output_ids = nodes_of_type(:output).map(&:id)

      input_ids.each_with_index { |id, idx| values[id] = inputs[idx] || 0.0 }
      (@node_genes.keys - input_ids).each { |id| values[id] = @node_genes[id].bias }

      incoming = Hash.new { |h, k| h[k] = [] }
      @connection_genes.each do |_, c|
        next unless c.enabled
        incoming[c.out_node] << c
      end

      order.each do |id|
        next if input_ids.include?(id)
        sum = values[id]
        incoming[id].each { |c| sum += (values[c.in_node] || 0.0) * c.weight }
        values[id] = Activations.call(@node_genes[id].activation, sum)
      end

      output_ids.map { |id| values[id] || 0.0 }
    end

    def topological_order
      in_degree = Hash.new(0)
      @node_genes.each { |id, _| in_degree[id] = 0 }
      adj = Hash.new { |h, k| h[k] = [] }

      @connection_genes.each do |_, c|
        next unless c.enabled
        adj[c.in_node] << c.out_node
        in_degree[c.out_node] += 1
      end

      queue = @node_genes.keys.select { |id| in_degree[id] == 0 }
      order = []

      while queue.any?
        id = queue.shift
        order << id
        adj[id].each do |nxt|
          in_degree[nxt] -= 1
          queue << nxt if in_degree[nxt] == 0
        end
      end

      if order.size != @node_genes.size
        raise CyclicNetworkError, "Network contains a cycle"
      end

      order
    end

    def compatibility_distance(other)
      innovations1 = @connection_genes.keys.sort
      innovations2 = other.connection_genes.keys.sort
      i = j = 0
      matching = disjoint = excess = 0
      weight_diff = 0.0

      while i < innovations1.size && j < innovations2.size
        g1 = innovations1[i]
        g2 = innovations2[j]

        if g1 == g2
          matching += 1
          weight_diff += (@connection_genes[g1].weight - other.connection_genes[g2].weight).abs
          i += 1
          j += 1
        elsif g1 < g2
          disjoint += 1
          i += 1
        else
          disjoint += 1
          j += 1
        end
      end

      excess = (innovations1.size - i) + (innovations2.size - j)
      n = [innovations1.size, innovations2.size].max
      n = 1 if n < 20
      avg_weight_diff = matching > 0 ? weight_diff / matching : 0.0

      (@config.excess_coefficient * excess / n) +
        (@config.disjoint_coefficient * disjoint / n) +
        (@config.weight_coefficient * avg_weight_diff)
    end

    def crossover(other)
      parent1, parent2 = @fitness >= other.fitness ? [self, other] : [other, self]
      child = Genome.new(@config, @tracker, build_initial: false)

      [parent1, parent2].each do |p|
        p.node_genes.each do |_, n|
          child.add_node(n.dup) if n.input? || n.output?
        end
      end

      keys = (parent1.connection_genes.keys + parent2.connection_genes.keys).uniq.sort
      keys.each do |innov|
        g1 = parent1.connection_genes[innov]
        g2 = parent2.connection_genes[innov]
        selected = nil

        if g1 && g2
          selected = (@config.rng.rand < 0.5 ? g1 : g2).dup
        elsif g1
          selected = g1.dup
        end

        if selected
          selected.enabled = true if !selected.enabled && @config.rng.rand < @config.reenable_rate
          child.add_connection(selected)
        end
      end

      child
    end

    def dup
      copy = Genome.new(@config, @tracker, build_initial: false)
      @node_genes.each { |_, n| copy.add_node(n.dup) }
      @connection_genes.each { |_, c| copy.add_connection(c.dup) }
      copy.fitness = @fitness
      copy
    end

    def nodes_of_type(type)
      @node_genes.values.select { |n| n.type == type }
    end
  end
end

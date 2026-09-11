module NEAT
  class InnovationTracker
    def initialize
      @counter = 0
      @connection_innovations = {}
      @node_splits = {}
    end

    def new_connection(in_node, out_node)
      key = [in_node, out_node]
      @connection_innovations[key] ||= begin
        @counter += 1
        @counter
      end
    end

    def new_node_split(in_node, out_node)
      key = [in_node, out_node]
      @node_splits[key] ||= begin
        node_id = (@counter += 1)
        in_connection = (@counter += 1)
        out_connection = (@counter += 1)
        [node_id, in_connection, out_connection]
      end
    end
  end
end

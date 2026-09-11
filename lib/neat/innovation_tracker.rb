module NEAT
  class InnovationTracker
    def initialize(next_node_id: 0)
      @counter = 0
      @next_node_id = next_node_id
      @connection_innovations = {}
      @node_splits = {}
    end

    def reserve_node_ids(count)
      @next_node_id = count if count > @next_node_id
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
        node_id = @next_node_id
        @next_node_id += 1
        in_connection = (@counter += 1)
        out_connection = (@counter += 1)
        [node_id, in_connection, out_connection]
      end
    end
  end
end

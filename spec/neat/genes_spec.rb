RSpec.describe NEAT::NodeGene do
  subject(:node) do
    described_class.new(1, :hidden, bias: 0.5, activation: :tanh, layer: 2)
  end

  it "stores its attributes" do
    expect(node.id).to eq(1)
    expect(node.type).to eq(:hidden)
    expect(node.bias).to eq(0.5)
    expect(node.activation).to eq(:tanh)
    expect(node.layer).to eq(2)
  end

  it "provides type predicates" do
    input = described_class.new(0, :input)
    output = described_class.new(2, :output)
    expect(input.input?).to be true
    expect(output.output?).to be true
    expect(node.hidden?).to be true
  end

  it "can be duplicated" do
    copy = node.dup
    expect(copy.id).to eq(node.id)
    expect(copy.bias).to eq(node.bias)
    expect(copy).not_to equal(node)
  end
end

RSpec.describe NEAT::ConnectionGene do
  subject(:connection) do
    described_class.new(0, 1, weight: 0.75, enabled: false, innovation: 5)
  end

  it "stores its attributes" do
    expect(connection.in_node).to eq(0)
    expect(connection.out_node).to eq(1)
    expect(connection.weight).to eq(0.75)
    expect(connection.enabled).to be false
    expect(connection.innovation).to eq(5)
  end

  it "can be duplicated" do
    copy = connection.dup
    expect(copy.in_node).to eq(connection.in_node)
    expect(copy.weight).to eq(connection.weight)
    expect(copy.enabled).to eq(connection.enabled)
    expect(copy).not_to equal(connection)
  end
end

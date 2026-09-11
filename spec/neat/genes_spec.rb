# frozen_string_literal: true

RSpec.describe NEAT::NodeGene do
  subject { described_class.new(1, :hidden, bias: 0.5, activation: :tanh, layer: 2) }

  it 'stores its attributes' do
    expect(subject.id).to eq(1)
    expect(subject.type).to eq(:hidden)
    expect(subject.bias).to eq(0.5)
    expect(subject.activation).to eq(:tanh)
    expect(subject.layer).to eq(2)
  end

  it 'provides type predicates' do
    input = described_class.new(0, :input)
    output = described_class.new(2, :output)
    expect(input.input?).to be true
    expect(output.output?).to be true
    expect(subject.hidden?).to be true
  end

  it 'can be duplicated' do
    copy = subject.dup
    expect(copy.id).to eq(subject.id)
    expect(copy.bias).to eq(subject.bias)
    expect(copy).not_to equal(subject)
  end
end

RSpec.describe NEAT::ConnectionGene do
  subject { described_class.new(0, 1, weight: 0.75, enabled: false, innovation: 5) }

  it 'stores its attributes' do
    expect(subject.in_node).to eq(0)
    expect(subject.out_node).to eq(1)
    expect(subject.weight).to eq(0.75)
    expect(subject.enabled).to be false
    expect(subject.innovation).to eq(5)
  end

  it 'can be duplicated' do
    copy = subject.dup
    expect(copy.in_node).to eq(subject.in_node)
    expect(copy.weight).to eq(subject.weight)
    expect(copy.enabled).to eq(subject.enabled)
    expect(copy).not_to equal(subject)
  end
end

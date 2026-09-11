# frozen_string_literal: true

RSpec.describe NEAT::InnovationTracker do
  subject { described_class.new }

  describe '#new_connection' do
    it 'assigns a unique innovation number to a new connection' do
      innov = subject.new_connection(0, 1)
      expect(innov).to be_a(Integer)
      expect(innov).to be > 0
    end

    it 'returns the same innovation number for the same ordered pair' do
      first = subject.new_connection(0, 1)
      second = subject.new_connection(0, 1)
      expect(second).to eq(first)
    end

    it 'assigns different innovation numbers to different connections' do
      a = subject.new_connection(0, 1)
      b = subject.new_connection(1, 2)
      expect(b).not_to eq(a)
    end
  end

  describe '#new_node_split' do
    it 'assigns innovations for the new node and its two connections' do
      node_id, in_conn, out_conn = subject.new_node_split(0, 1)
      expect(node_id).to be_a(Integer)
      expect(in_conn).to be_a(Integer)
      expect(out_conn).to be_a(Integer)
      expect(in_conn).not_to eq(node_id)
      expect(out_conn).not_to eq(node_id)
    end

    it 'returns the same innovations for the same split' do
      first = subject.new_node_split(0, 1)
      second = subject.new_node_split(0, 1)
      expect(second).to eq(first)
    end

    it 'assigns node ids at or above the reserved floor' do
      subject.reserve_node_ids(5)
      node_id, = subject.new_node_split(0, 1)
      expect(node_id).to be >= 5
    end
  end
end

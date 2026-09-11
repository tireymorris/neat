RSpec.describe NEAT::Activations do
  describe ".call" do
    it "computes the NEAT sigmoid" do
      expect(NEAT::Activations.call(:sigmoid, 0.0)).to be_within(0.001).of(0.5)
    end

    it "computes tanh" do
      expect(NEAT::Activations.call(:tanh, 0.0)).to be_within(0.001).of(0.0)
    end

    it "computes relu" do
      expect(NEAT::Activations.call(:relu, -1.0)).to eq(0.0)
      expect(NEAT::Activations.call(:relu, 2.0)).to eq(2.0)
    end

    it "raises for unknown activations" do
      expect { NEAT::Activations.call(:unknown, 1.0) }.to raise_error(NEAT::Error)
    end
  end
end

RSpec.describe NEAT do
  it "is a module" do
    expect(NEAT).to be_a(Module)
  end

  describe NEAT::Error do
    it "inherits from StandardError" do
      expect(NEAT::Error.superclass).to eq(StandardError)
    end
  end
end

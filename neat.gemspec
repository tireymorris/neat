Gem::Specification.new do |spec|
  spec.name = "neat"
  spec.version = "0.1.0"
  spec.authors = ["Your Name"]
  spec.summary = "NEAT (NeuroEvolution of Augmenting Topologies) library for Ruby"
  spec.files = Dir.glob("lib/**/*")
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rspec", "~> 3.13"
end

Gem::Specification.new do |spec|
  spec.name = "neat"
  spec.version = "0.1.0"
  spec.authors = ["Tim Morris"]
  spec.summary = "NEAT (NeuroEvolution of Augmenting Topologies) library for Ruby"
  spec.description = "Evolve neural network topologies and weights with speciation, historical marking, and structural mutation."
  spec.homepage = "https://github.com/tireymorris/neat"
  spec.license = "MIT"
  spec.files = Dir.glob("{lib,bin}/**/*") + %w[README.md LICENSE]
  spec.bindir = "bin"
  spec.executables = ["neat"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rspec", "~> 3.13"
end

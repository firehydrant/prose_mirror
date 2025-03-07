require_relative "lib/prose_mirror/version"

Gem::Specification.new do |spec|
  spec.name = "prose_mirror"
  spec.version = ProseMirror::VERSION
  spec.authors = ["Robert Ross"]
  spec.email = ["robert@firehydrant.com"]

  spec.summary = "Ruby implementation of ProseMirror document model"
  spec.description = "A library for working with ProseMirror documents in Ruby, including conversion between ProseMirror JSON and other formats such as Markdown."
  spec.homepage = "https://github.com/firehydrant/prose_mirror"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/firehydrant/prose_mirror"
  spec.metadata["changelog_uri"] = "https://github.com/firehydrant/prose_mirror/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.glob("lib/**/*") + ["LICENSE.txt", "README.md", "CHANGELOG.md"]
  spec.require_paths = ["lib"]

  # Dependencies
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end

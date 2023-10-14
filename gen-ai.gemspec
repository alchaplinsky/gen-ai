# frozen_string_literal: true

require_relative "lib/gen_ai/version"

Gem::Specification.new do |spec|
  spec.name = "gen-ai"
  spec.version = GenAI::VERSION
  spec.authors = ["Alex Chaplinsky"]
  spec.email = ["alchaplinsky@gmail.com"]

  spec.summary = "Generative AI toolset for Ruby."
  spec.description = "Generative AI toolset for Ruby."
  spec.homepage = "https://github.com/alchaplinsky/gen-ai"
  spec.required_ruby_version = ">= 2.6.0"

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/alchaplinsky/gen-ai"
  spec.metadata["changelog_uri"] = "https://github.com/alchaplinsky/gen-ai/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "zeitwerk", "~> 2.6"

  spec.add_development_dependency "ruby-openai", "~> 5.1.0"
  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end

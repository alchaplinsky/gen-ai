# frozen_string_literal: true

module GenAI
  module Dependency
    class VersionError < StandardError; end

    def depends_on(*names)
      names.each { |name| load_dependency(name) }
    end

    private

    def load_dependency(name)
      gem(name)

      return true unless defined? Bundler

      gem_spec = Gem::Specification.find_by_name(name)
      gem_requirement = dependencies.find { |gem| gem.name == gem_spec.name }.requirement

      unless gem_requirement.satisfied_by?(gem_spec.version)
        raise VersionError, version_error(gem_spec, gem_requirement)
      end

      require_gem(gem_spec)
    end

    def version_error(gem_spec, gem_requirement)
      "'#{gem_spec.name}' gem version is #{gem_spec.version}, but your Gemfile specified #{gem_requirement}."
    end

    def require_gem(gem_spec)
      gem_spec.full_require_paths.each do |path|
        Dir.glob("#{path}/*.rb").each { |file| require file }
      end
    end

    def dependencies
      Bundler.load.dependencies
    end
  end
end

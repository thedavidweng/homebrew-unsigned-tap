# typed: strict
# frozen_string_literal: true

require "cask/cask_loader"
require "macos_version"
require "open3"
require "simulate_system"
require "utils/bottles"

abort "usage: check_cask_compatibility.rb BASE HEAD" if ARGV.length != 2
base, head = ARGV
architectures = [:arm, :intel].freeze

git = lambda do |*args|
  stdout, stderr, status = Open3.capture3("git", *args)
  abort stderr unless status.success?
  stdout
end

paths = git.call("diff", "--name-only", "--diff-filter=M", base, head, "--", "Casks/*.rb").lines.map(&:chomp)
lost = []
paths.each do |path|
  sources = [base, head].map { |ref| git.call("show", "#{ref}:#{path}") }
  MacOSVersion::SYMBOLS.each_key do |os|
    architectures.each do |arch|
      supported = Homebrew::SimulateSystem.with(os: os, arch: arch) do
        tag = Utils::Bottles::Tag.new(system: os, arch: arch)
        sources.map do |source|
          cask = Cask::CaskLoader::FromContentLoader.new(source).load(config: nil)
          cask.platform_supported?(tag)
        end
      end
      lost << "#{path}: #{os} / #{arch}" if supported == [true, false]
    end
  end
end

abort "Cask update removes declared platform support:\n#{lost.join("\n")}" unless lost.empty?
puts "No declared macOS platform support removed from #{paths.length} cask(s)."

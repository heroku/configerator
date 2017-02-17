VERSIONS = %w[ 2.0 2.1 2.2 2.3 latest ].freeze

def dcrm_test(version: "latest")
  test = version == "latest" ? "test" \
    : "test_#{version.gsub(".", "_")}"

  sh("docker-compose run --rm #{test}")
end

begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec)

rescue LoadError
  desc "Run specs using Docker on Ruby (latest)"
  task :spec do
    dcrm_test
  end
end

task default: :spec

desc "Run specs on all support Ruby versions using Docker"
task :regression do |_, args|
  versions = args.to_a.select { |a| VERSIONS.include?(a) }

  if versions.empty?
    versions = VERSIONS
    dcrm_test
  end

  versions.each do |version|
    dcrm_test(version: version)
  end
end

VERSIONS.each do |version|
  desc "Run specs using Docker on Ruby (#{version})"
  task "spec:#{version}" do
    dcrm_test(version: version)
  end
end

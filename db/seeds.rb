# frozen_string_literal: true

seeded_at = Time.zone.local(2026, 4, 18, 9, 0, 0)

Octochangelog::DemoCatalog.seed_runs.each_with_index do |attributes, index|
  comparison_run = ComparisonRun.find_or_initialize_by(
    repository_full_name: attributes.fetch(:repository_full_name),
    from_version: attributes.fetch(:from_version),
    to_version: attributes.fetch(:to_version)
  )

  comparison_run.assign_attributes(
    github_authenticated: false,
    created_at: seeded_at + index.hours,
    updated_at: seeded_at + index.hours
  )
  comparison_run.save!
end

puts "Seeded #{Octochangelog::DemoCatalog.seed_runs.size} canonical comparison runs."

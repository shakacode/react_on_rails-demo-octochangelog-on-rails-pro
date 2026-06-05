# frozen_string_literal: true

require "test_helper"

module Octochangelog
  class DemoCatalogTest < ActiveSupport::TestCase
    test "builds featured comparisons with generated compare links" do
      featured = Octochangelog::DemoCatalog.featured_comparisons(
        compare_path: ->(repo:, from:, to:) { "/compare?repo=#{repo}&from=#{from}&to=#{to}" }
      )

      assert_equal Octochangelog::DemoCatalog::FEATURED_COMPARISONS.size, featured.size
      assert_equal "ESLint Testing Library", featured.first.fetch(:label)
      assert_equal "testing-library/eslint-plugin-testing-library", featured.first.fetch(:repo)
      assert_equal "/compare?repo=testing-library/eslint-plugin-testing-library&from=v6.5.0&to=latest", featured.first.fetch(:href)
    end

    test "exposes deterministic seed runs without presentation-only fields" do
      seed_runs = Octochangelog::DemoCatalog.seed_runs

      assert_operator seed_runs.size, :>=, Octochangelog::DemoCatalog::FEATURED_COMPARISONS.size
      assert_includes seed_runs, {
        repository_full_name: "octokit/rest.js",
        from_version: "22.0.0",
        to_version: "latest"
      }
      assert seed_runs.all? { |run| run.keys.sort == %i[from_version repository_full_name to_version] }
    end
  end
end

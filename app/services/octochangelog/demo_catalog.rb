# frozen_string_literal: true

module Octochangelog
  module DemoCatalog
    module_function

    FEATURED_COMPARISONS = [
      {
        label: "ESLint Testing Library",
        note: "The original Octochangelog example, useful for checking visual parity with the upstream app.",
        repo: "testing-library/eslint-plugin-testing-library",
        from: "v6.5.0",
        to: "latest"
      },
      {
        label: "TanStack Router",
        note: "A library-sized changelog with enough version depth to stress the parser.",
        repo: "TanStack/router",
        from: "1.120.5",
        to: "latest"
      },
      {
        label: "Vite",
        note: "Good for showing off grouped notes, code blocks, and markdown-heavy releases.",
        repo: "vitejs/vite",
        from: "6.0.0",
        to: "latest"
      },
      {
        label: "React on Rails",
        note: "A meta demo: compare React on Rails releases inside the React on Rails Pro port.",
        repo: "shakacode/react_on_rails",
        from: "16.0.0",
        to: "latest"
      }
    ].freeze

    SEED_RUNS = [
      *FEATURED_COMPARISONS,
      {
        label: "Octokit",
        note: "Compact API client history that usually produces a quick, readable compare run.",
        repo: "octokit/rest.js",
        from: "22.0.0",
        to: "latest"
      },
      {
        label: "React",
        note: "Widely recognized repo that helps the demo land quickly with engineering audiences.",
        repo: "facebook/react",
        from: "19.0.0",
        to: "latest"
      },
      {
        label: "Rails",
        note: "Shows the same pattern against a mainstream Ruby project.",
        repo: "rails/rails",
        from: "8.0.0",
        to: "latest"
      }
    ].freeze

    def featured_comparisons(compare_path:)
      FEATURED_COMPARISONS.map do |comparison|
        comparison.merge(
          href: compare_path.call(
            repo: comparison.fetch(:repo),
            from: comparison.fetch(:from),
            to: comparison.fetch(:to)
          )
        )
      end
    end

    def seed_runs
      SEED_RUNS.map do |comparison|
        {
          repository_full_name: comparison.fetch(:repo),
          from_version: comparison.fetch(:from),
          to_version: comparison.fetch(:to)
        }
      end
    end
  end
end

# frozen_string_literal: true

class HomeController < ApplicationController
  include ReactOnRailsPro::Stream

  layout "react_on_rails_default"

  def index
    @home_page_props = {
      comparePath: compare_path,
      distinctRepositories: ComparisonRun.distinct.count(:repository_full_name),
      featuredComparisons: featured_comparisons,
      recentRuns: recent_runs,
      sourceName: "Octochangelog",
      sourceUrl: "https://github.com/Belco90/octochangelog",
      totalComparisons: ComparisonRun.count
    }

    stream_view_containing_react_components(template: "home/index")
  end

  private

  def featured_comparisons
    [
      {
        label: "TanStack Router",
        note: "A library-sized changelog with enough version depth to stress the parser.",
        href: compare_path(repo: "TanStack/router", from: "1.120.5", to: "latest"),
        repo: "TanStack/router",
        from: "1.120.5",
        to: "latest"
      },
      {
        label: "Vite",
        note: "Good for showing off grouped notes, code blocks, and markdown-heavy releases.",
        href: compare_path(repo: "vitejs/vite", from: "6.0.0", to: "latest"),
        repo: "vitejs/vite",
        from: "6.0.0",
        to: "latest"
      },
      {
        label: "React on Rails",
        note: "A meta demo: compare React on Rails releases inside the React on Rails Pro port.",
        href: compare_path(repo: "shakacode/react_on_rails", from: "16.0.0", to: "latest"),
        repo: "shakacode/react_on_rails",
        from: "16.0.0",
        to: "latest"
      }
    ]
  end

  def recent_runs
    ComparisonRun.recent.limit(6).map do |run|
      {
        createdAtLabel: run.created_at.in_time_zone.strftime("%b %-d, %Y · %-l:%M %p"),
        fromVersion: run.from_version,
        href: compare_path(repo: run.repository_full_name, from: run.from_version, to: run.to_version),
        id: run.id,
        repositoryFullName: run.repository_full_name,
        toVersion: run.to_version
      }
    end
  end
end

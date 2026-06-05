# frozen_string_literal: true

class HomeController < ApplicationController
  include ReactOnRailsPro::Stream

  layout "react_on_rails_default"

  def index
    @home_page_props = {
      comparePath: compare_path,
      featuredComparisons: featured_comparisons,
      recentRuns: recent_runs,
      sourceName: "Octochangelog",
      sourceUrl: "https://github.com/Belco90/octochangelog"
    }

    stream_view_containing_react_components(template: "home/index")
  end

  private

  def featured_comparisons
    Octochangelog::DemoCatalog.featured_comparisons(compare_path: method(:compare_path))
  end

  def recent_runs
    ComparisonRun.recent.limit(Octochangelog::DemoCatalog.seed_runs.size).map do |run|
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

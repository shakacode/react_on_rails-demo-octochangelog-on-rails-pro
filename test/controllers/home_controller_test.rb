require "test_helper"
require "rack/utils"
require "uri"

class HomeControllerTest < ActionController::TestCase
  tests HomeController

  setup do
    ComparisonRun.delete_all
    stub_stream_render
  end

  test "index builds home page props from recent comparison history" do
    older_run = nil
    newer_run = nil

    travel_to Time.zone.parse("2026-04-22 21:25:00") do
      older_run = ComparisonRun.create!(
        repository_full_name: "rails/rails",
        from_version: "8.0.0",
        to_version: "latest"
      )
    end

    travel_to Time.zone.parse("2026-04-22 21:36:00") do
      newer_run = ComparisonRun.create!(
        repository_full_name: "octokit/rest.js",
        from_version: "22.0.0",
        to_version: "latest"
      )

      get :index
    end

    assert_response :success
    assert_match(%r{application[^"]*\.css}, response.body)

    props = @controller.instance_variable_get(:@home_page_props)
    assert_equal "/compare", props[:comparePath]
    assert_equal 2, props[:distinctRepositories]
    assert_equal 2, props[:totalComparisons]
    assert_equal "Octochangelog", props[:sourceName]
    assert_equal "https://github.com/Belco90/octochangelog", props[:sourceUrl]
    assert_equal Octochangelog::DemoCatalog::FEATURED_COMPARISONS.size, props[:featuredComparisons].size

    first_featured = props[:featuredComparisons].first
    assert_equal "TanStack Router", first_featured[:label]
    assert_equal(
      { "from" => "1.120.5", "repo" => "TanStack/router", "to" => "latest" },
      query_params_for(first_featured[:href])
    )

    assert_equal [ newer_run.id, older_run.id ], props[:recentRuns].map { |run| run[:id] }
    assert_equal newer_run.repository_full_name, props[:recentRuns].first[:repositoryFullName]
    assert_equal newer_run.created_at.in_time_zone.strftime("%b %-d, %Y · %-l:%M %p"), props[:recentRuns].first[:createdAtLabel]
    assert_equal(
      {
        "from" => newer_run.from_version,
        "repo" => newer_run.repository_full_name,
        "to" => newer_run.to_version
      },
      query_params_for(props[:recentRuns].first[:href])
    )
  end

  private

  def query_params_for(path)
    uri = URI.parse("http://example.test#{path}")
    Rack::Utils.parse_nested_query(uri.query)
  end

  def stub_stream_render
    @controller.define_singleton_method(:stream_view_containing_react_components) do |template:|
      render inline: "<p>stubbed #{template}</p>", layout: "react_on_rails_default"
    end
  end
end

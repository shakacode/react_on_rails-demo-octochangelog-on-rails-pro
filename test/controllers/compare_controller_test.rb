require "test_helper"

class CompareControllerTest < ActionController::TestCase
  FakeGithubApiClient = Struct.new(:repository_payload, :releases_payload, :error_message) do
    def repository(owner:, repo:)
      raise Github::Client::Error, error_message if error_message.present?

      repository_payload
    end

    def stable_releases(owner:, repo:, max_pages: 10)
      raise Github::Client::Error, error_message if error_message.present?

      releases_payload
    end
  end

  tests CompareController

  setup do
    ComparisonRun.delete_all
    stub_stream_render
  end

  test "index builds compare props and persists valid comparison runs" do
    stub_github_client(
      FakeGithubApiClient.new(
        {
          "full_name" => "octokit/rest.js",
          "html_url" => "https://github.com/octokit/rest.js",
          "id" => 7,
          "name" => "rest.js",
          "owner" => { "login" => "octokit" }
        },
        [
          release_payload(id: 3, tag_name: "v22.2.0"),
          release_payload(id: 2, tag_name: "v22.1.0"),
          release_payload(id: 1, tag_name: "v22.0.0")
        ]
      )
    )

    assert_difference("ComparisonRun.count", 1) do
      get :index, params: { repo: "octokit/rest.js", from: "22.0.0", to: "latest" }
    end

    assert_response :success
    assert_match(%r{application[^"]*\.css}, response.body)

    filters = @controller.instance_variable_get(:@compare_filters_props)
    assert_equal false, filters[:authEnabled]
    assert_equal false, filters[:authenticated]
    assert_equal "/compare", filters[:comparePath]
    assert_equal "octokit/rest.js", filters[:repo]
    assert_equal "22.0.0", filters[:from]
    assert_equal "latest", filters[:to]
    assert_equal "/auth/github", filters[:loginPathBase]
    assert_equal "/auth/github", filters[:logoutPath]
    assert_equal "/api/github/repositories", filters[:repositoriesEndpoint]
    assert_equal "/api/github/releases", filters[:releasesEndpoint]
    assert filters[:csrfToken].present?

    results = @controller.instance_variable_get(:@compare_results_props)
    assert_equal false, results[:authEnabled]
    assert_equal false, results[:authenticated]
    assert_equal "22.0.0", results[:from]
    assert_equal "latest", results[:to]
    assert_nil results.dig(:comparison, :error)
    assert_equal "octokit/rest.js", results.dig(:comparison, :repository, :fullName)
    assert_equal 3, results.dig(:comparison, :totalStableReleases)
    assert_equal [ "v22.2.0", "v22.1.0" ], results.dig(:comparison, :releases).map { |release| release[:tagName] }

    comparison_run = ComparisonRun.last
    assert_equal "octokit/rest.js", comparison_run.repository_full_name
    assert_equal "22.0.0", comparison_run.from_version
    assert_equal "latest", comparison_run.to_version
    assert_equal false, comparison_run.github_authenticated
  end

  test "index skips persistence and comparison lookup for invalid repository params" do
    stub_github_client(
      FakeGithubApiClient.new(
        {},
        [],
        "This client should not be called for invalid repository params."
      )
    )

    assert_no_difference("ComparisonRun.count") do
      get :index, params: { repo: "octokit", from: "22.0.0", to: "latest" }
    end

    assert_response :success

    filters = @controller.instance_variable_get(:@compare_filters_props)
    assert_equal "octokit", filters[:repo]

    results = @controller.instance_variable_get(:@compare_results_props)
    assert_nil results[:comparison]
  end

  test "index surfaces github client failures inside the comparison payload" do
    stub_github_client(
      FakeGithubApiClient.new(
        {},
        [],
        "GitHub API rate limit exceeded for this demo request."
      )
    )

    assert_difference("ComparisonRun.count", 1) do
      get :index, params: { repo: "octokit/rest.js", from: "22.0.0", to: "latest" }
    end

    assert_response :success

    comparison = @controller.instance_variable_get(:@compare_results_props).fetch(:comparison)
    assert_equal "GitHub API rate limit exceeded for this demo request.", comparison[:error]
    assert_equal [], comparison[:releases]
    assert_nil comparison[:repository]
    assert_equal 0, comparison[:totalStableReleases]
  end

  private

  def release_payload(id:, tag_name:)
    {
      "body" => "## Highlights",
      "html_url" => "https://github.com/octokit/rest.js/releases/tag/#{tag_name}",
      "id" => id,
      "name" => tag_name,
      "published_at" => "2026-04-02T00:00:00Z",
      "tag_name" => tag_name
    }
  end

  def stub_github_client(fake_client)
    @controller.define_singleton_method(:github_client) do
      fake_client
    end
  end

  def stub_stream_render
    @controller.define_singleton_method(:stream_view_containing_react_components) do |template:|
      render inline: "<p>stubbed #{template}</p>", layout: "react_on_rails_default"
    end
  end
end

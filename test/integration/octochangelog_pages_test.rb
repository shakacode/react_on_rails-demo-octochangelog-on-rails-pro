require "test_helper"

class OctochangelogPagesTest < ActionDispatch::IntegrationTest
  FakeGithubClient = Struct.new(:repository_payload, :releases_payload) do
    def repository(owner:, repo:)
      repository_payload.merge(
        "full_name" => "#{owner}/#{repo}",
        "name" => repo,
        "owner" => { "login" => owner }
      )
    end

    def stable_releases(owner:, repo:)
      releases_payload
    end
  end

  def with_stubbed_github_client(fake_client)
    original_new = Github::Client.method(:new)

    Github::Client.define_singleton_method(:new) do |*args, **kwargs|
      fake_client
    end

    yield
  ensure
    Github::Client.define_singleton_method(:new) do |*args, **kwargs|
      original_new.call(*args, **kwargs)
    end
  end

  test "home page presents Octochangelog product parity and Rails powered positioning" do
    get root_url

    assert_response :success
    assert_select "header.octo-app-header"
    assert_select "img[alt='Octochangelog mascot']"
    assert_select "h1", "Octochangelog"
    assert_select "h2", "Compare GitHub changelogs in a single view"
    assert_select "a[href='#{compare_path}']", /Compare changelogs/
    assert_select "a[href*='testing-library%2Feslint-plugin-testing-library']", /See example/
    assert_select ".octo-feature-card h3", "Compare releases easily"
    assert_select ".octo-feature-card h3", "Share changelogs"
    assert_select ".octo-feature-card h3", "Don't miss breaking changes"
    assert_select ".octo-feature-card h3", "No manual sorting"
    assert_select ".octo-feature-card h3", "Changes per version"
    assert_includes response.body, "Powered by React on Rails Pro, React Server Components, and Control Plane"
  end

  test "compare page renders the product first filter studio and empty state" do
    get compare_url

    assert_response :success
    assert_select "header.octo-app-header"
    assert_select "main.octo-page--compare"
    assert_select "h1", "Compare changelogs"
    assert_select "input[name='repo']"
    assert_select "select[name='from']"
    assert_select "select[name='to']"
    assert_select "button[type='submit']", "Compare releases"
    assert_select ".octo-empty-state h2", /Choose a repository and version window/
    assert_includes response.body, "Rails streams the grouped release notes"
  end

  test "compare request persists history and renders server grouped release notes" do
    fake_client = FakeGithubClient.new(
      {
        "html_url" => "https://github.com/octo/example",
        "id" => 101
      },
      [
        {
          "body" => "## **Breaking Changes**\n\n- Removed deprecated API.\n\n## Features\n\n- Added a faster parser.",
          "html_url" => "https://github.com/octo/example/releases/tag/v2.0.0",
          "id" => 2,
          "name" => "v2.0.0",
          "published_at" => "2026-04-02T00:00:00Z",
          "tag_name" => "v2.0.0"
        },
        {
          "body" => "## Bug Fixes\n\n- Patched a renderer issue.",
          "html_url" => "https://github.com/octo/example/releases/tag/v1.0.0",
          "id" => 1,
          "name" => "v1.0.0",
          "published_at" => "2026-03-01T00:00:00Z",
          "tag_name" => "v1.0.0"
        }
      ]
    )

    with_stubbed_github_client(fake_client) do
      assert_difference "ComparisonRun.count", 1 do
        get compare_url(repo: "octo/example", from: "1.0.0", to: "latest")
      end
    end

    assert_response :success
    assert_equal "octo/example", ComparisonRun.order(:created_at).last.repository_full_name
    assert_select "input[type='hidden'][name='from'][value='1.0.0']"
    assert_select "input[type='hidden'][name='to'][value='latest']"
    assert_select ".octo-results-panel h2", "octo/example"
    assert_select ".octo-group-header h3", "Breaking Changes"
    assert_select ".octo-release-card", /Removed deprecated API/
    assert_select ".octo-summary-card", /Releases in range/
  end
end

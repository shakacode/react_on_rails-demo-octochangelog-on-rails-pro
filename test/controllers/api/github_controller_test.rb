require "test_helper"

class Api::GithubControllerTest < ActionDispatch::IntegrationTest
  FakeGithubApiClient = Struct.new(:repositories_payload, :releases_payload) do
    def search_repositories(query:, per_page: 8)
      repositories_payload
    end

    def stable_releases(owner:, repo:, max_pages: 10)
      releases_payload
    end
  end

  def with_stubbed_client(fake_client)
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

  test "maps repository search results" do
    fake_client = FakeGithubApiClient.new(
      [
        {
          "description" => "A test repository",
          "full_name" => "octo/example",
          "html_url" => "https://github.com/octo/example",
          "id" => 5,
          "language" => "TypeScript",
          "stargazers_count" => 128
        }
      ],
      []
    )

    with_stubbed_client(fake_client) do
      get api_github_repositories_url, params: { q: "example" }
    end

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal "octo/example", payload.dig("items", 0, "fullName")
    assert_equal 128, payload.dig("items", 0, "stargazersCount")
  end

  test "maps release results with extracted versions" do
    fake_client = FakeGithubApiClient.new(
      [],
      [
        {
          "html_url" => "https://github.com/octo/example/releases/tag/v2.1.0",
          "id" => 7,
          "name" => "v2.1.0",
          "published_at" => "2026-04-02T00:00:00Z",
          "tag_name" => "v2.1.0"
        }
      ]
    )

    with_stubbed_client(fake_client) do
      get api_github_releases_url, params: { repo: "octo/example" }
    end

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal "2.1.0", payload.dig("items", 0, "version")
  end
end

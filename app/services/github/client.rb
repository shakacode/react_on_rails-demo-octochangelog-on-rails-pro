# frozen_string_literal: true

require "json"
require "net/http"

module Github
  class Client
    Error = Class.new(StandardError)

    API_BASE = "https://api.github.com"
    OAUTH_TOKEN_ENDPOINT = "https://github.com/login/oauth/access_token"
    USER_AGENT = "OctochangelogOnRailsPro"

    def self.extract_version(tag_name)
      raw_value = tag_name.to_s.split("/").last.to_s.delete_prefix("v")
      raw_value
    end

    def self.filter_releases_by_range(releases, from:, to:)
      return [] if releases.blank?

      to_version =
        if to.to_s.casecmp("latest").zero?
          extract_version(releases.first["tag_name"])
        else
          extract_version(to)
        end

      from_version = extract_version(from)
      return [] unless comparable_version?(from_version) && comparable_version?(to_version)

      releases.select do |release|
        release_version = extract_version(release["tag_name"])
        next false unless comparable_version?(release_version)

        Gem::Version.new(release_version) > Gem::Version.new(from_version) &&
          Gem::Version.new(release_version) <= Gem::Version.new(to_version)
      end
    end

    def initialize(access_token: nil)
      @access_token = access_token.presence
    end

    def exchange_code_for_access_token(code:, redirect_uri:)
      response = post_json(
        OAUTH_TOKEN_ENDPOINT,
        {
          client_id: ENV.fetch("GITHUB_CLIENT_ID"),
          client_secret: ENV.fetch("GITHUB_CLIENT_SECRET"),
          code: code,
          redirect_uri: redirect_uri
        }
      )

      token = response["access_token"]
      raise Error, response["error_description"].presence || "GitHub OAuth exchange failed." if token.blank?

      token
    end

    def search_repositories(query:, per_page: 8)
      payload = cacheable_get_json(
        "/search/repositories",
        order: "desc",
        per_page: per_page,
        q: query,
        sort: "stars"
      )

      Array(payload.fetch("items", []))
    end

    def repository(owner:, repo:)
      cacheable_get_json("/repos/#{owner}/#{repo}")
    end

    def stable_releases(owner:, repo:, max_pages: 10)
      releases = []

      1.upto(max_pages) do |page|
        response, headers = get_json_with_headers(
          "/repos/#{owner}/#{repo}/releases",
          page: page,
          per_page: 100
        )

        releases.concat(Array(response).select { |release| stable_release?(release["tag_name"]) })
        break unless headers.fetch("link", "").include?('rel="next"')
      end

      releases
    end

    private

    def self.comparable_version?(version)
      Gem::Version.correct?(version) && !Gem::Version.new(version).prerelease?
    end

    def cacheable_get_json(path, **query)
      return get_json(path, **query) if @access_token.present?

      Rails.cache.fetch([ "github-client", path, query ], expires_in: 10.minutes) do
        get_json(path, **query)
      end
    end

    def get_json(path, **query)
      response, = get_json_with_headers(path, **query)
      response
    end

    def get_json_with_headers(path, **query)
      uri = URI("#{API_BASE}#{path}")
      uri.query = URI.encode_www_form(query.compact)

      request = Net::HTTP::Get.new(uri)
      request["Accept"] = "application/vnd.github+json"
      request["User-Agent"] = USER_AGENT
      request["X-GitHub-Api-Version"] = "2022-11-28"
      request["Authorization"] = "Bearer #{@access_token}" if @access_token.present?

      payload, response = perform(request, uri)
      [ payload, response.to_hash ]
    end

    def perform(request, uri)
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      payload = response.body.present? ? JSON.parse(response.body) : {}
      return [ payload, response ] if response.is_a?(Net::HTTPSuccess)

      message =
        payload["message"].presence ||
        response.message.presence ||
        "GitHub request failed with status #{response.code}"

      raise Error, message
    rescue JSON::ParserError => error
      raise Error, "GitHub response could not be parsed: #{error.message}"
    end

    def post_json(url, body)
      uri = URI(url)
      request = Net::HTTP::Post.new(uri)
      request["Accept"] = "application/json"
      request["Content-Type"] = "application/json"
      request["User-Agent"] = USER_AGENT
      request.body = JSON.generate(body)

      payload, = perform(request, uri)
      payload
    end

    def stable_release?(tag_name)
      version = self.class.extract_version(tag_name)
      self.class.comparable_version?(version)
    end
  end
end

# frozen_string_literal: true

module Api
  class GithubController < ApplicationController
    def repositories
      query = params[:q].to_s.strip
      if query.blank?
        render json: { items: [] }
        return
      end

      repositories = github_client.search_repositories(query: query).map do |repo|
        {
          description: repo["description"],
          fullName: repo["full_name"],
          htmlUrl: repo["html_url"],
          id: repo["id"],
          language: repo["language"],
          stargazersCount: repo["stargazers_count"]
        }
      end

      render json: { items: repositories }
    rescue Github::Client::Error => error
      render json: { error: error.message }, status: :bad_gateway
    end

    def releases
      repo_name = params[:repo].to_s
      owner, repo = repo_name.split("/", 2)
      if owner.blank? || repo.blank?
        render json: { items: [] }
        return
      end

      releases = github_client.stable_releases(owner: owner, repo: repo).map do |release|
        {
          id: release["id"],
          name: release["name"],
          publishedAt: release["published_at"],
          tagName: release["tag_name"],
          url: release["html_url"],
          version: Github::Client.extract_version(release["tag_name"])
        }
      end

      render json: { items: releases }
    rescue Github::Client::Error => error
      render json: { error: error.message }, status: :bad_gateway
    end

    private

    def github_client
      @github_client ||= Github::Client.new(access_token: session[:github_access_token])
    end
  end
end

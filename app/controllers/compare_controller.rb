# frozen_string_literal: true

class CompareController < ApplicationController
  include ReactOnRailsPro::Stream

  layout "react_on_rails_default"

  before_action :persist_comparison_run, if: :comparison_requested?

  def index
    @compare_filters_props = {
      authEnabled: github_auth_configured?,
      authenticated: github_authenticated?,
      comparePath: compare_path,
      csrfToken: form_authenticity_token,
      from: compare_params[:from],
      initialFrom: compare_params[:from],
      initialRepo: compare_params[:repo],
      initialTo: compare_params[:to],
      loginPathBase: github_auth_start_path,
      logoutPath: github_auth_path,
      releasesEndpoint: api_github_releases_path,
      repo: compare_params[:repo],
      repositoriesEndpoint: api_github_repositories_path,
      to: compare_params[:to]
    }
    @compare_results_props = {
      authEnabled: github_auth_configured?,
      authenticated: github_authenticated?,
      comparison: comparison_payload,
      from: compare_params[:from],
      to: compare_params[:to]
    }
    @compare_flash = flash_payload

    stream_view_containing_react_components(template: "compare/index")
  end

  private

  def compare_params
    params.permit(:repo, :from, :to)
  end

  def comparison_requested?
    compare_params.values_at(:repo, :from, :to).all?(&:present?) && compare_params[:repo].count("/") == 1
  end

  def comparison_payload
    return nil unless comparison_requested?

    owner, repo = compare_params[:repo].split("/", 2)
    repository = github_client.repository(owner: owner, repo: repo)
    releases = github_client.stable_releases(owner: owner, repo: repo)
    filtered_releases = Github::Client.filter_releases_by_range(
      releases,
      from: compare_params[:from],
      to: compare_params[:to]
    )

    {
      error: nil,
      releases: filtered_releases.map do |release|
        {
          body: release["body"],
          id: release["id"],
          name: release["name"],
          publishedAt: release["published_at"],
          tagName: release["tag_name"],
          url: release["html_url"]
        }
      end,
      repository: {
        fullName: repository["full_name"],
        htmlUrl: repository["html_url"],
        id: repository["id"],
        name: repository["name"],
        ownerLogin: repository.dig("owner", "login")
      },
      totalStableReleases: releases.length
    }
  rescue Github::Client::Error => error
    {
      error: error.message,
      releases: [],
      repository: nil,
      totalStableReleases: 0
    }
  end

  def flash_payload
    if flash[:alert].present?
      { message: flash[:alert], tone: "danger" }
    elsif flash[:notice].present?
      { message: flash[:notice], tone: "success" }
    end
  end

  def persist_comparison_run
    ComparisonRun.create!(
      from_version: compare_params[:from],
      github_authenticated: github_authenticated?,
      repository_full_name: compare_params[:repo],
      to_version: compare_params[:to]
    )
  rescue ActiveRecord::RecordInvalid
    nil
  end

  def github_client
    @github_client ||= Github::Client.new(access_token: session[:github_access_token])
  end
end

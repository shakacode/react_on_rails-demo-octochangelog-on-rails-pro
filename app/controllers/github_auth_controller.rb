# frozen_string_literal: true

class GithubAuthController < ApplicationController
  OAUTH_REDIRECT_PATH_KEY = :github_auth_redirect_path
  OAUTH_STATE_KEY = :github_oauth_state

  def start
    unless github_auth_configured?
      redirect_to compare_path(request_query_params), alert: "GitHub OAuth is not configured for this environment."
      return
    end

    session[OAUTH_REDIRECT_PATH_KEY] = compare_path(request_query_params)
    session[OAUTH_STATE_KEY] = SecureRandom.hex(24)

    redirect_to authorize_url(session[OAUTH_STATE_KEY]), allow_other_host: true
  end

  def callback
    unless github_auth_configured?
      redirect_to compare_path, alert: "GitHub OAuth is not configured for this environment."
      return
    end

    if params[:code].blank?
      redirect_to redirect_path, alert: "GitHub did not return an authorization code."
      return
    end

    expected_state = session.delete(OAUTH_STATE_KEY).to_s
    actual_state = params[:state].to_s
    if expected_state.blank? || actual_state.blank?
      redirect_to redirect_path, alert: "GitHub authorization state was missing. Please try again."
      return
    end

    unless ActiveSupport::SecurityUtils.secure_compare(actual_state, expected_state)
      redirect_to redirect_path, alert: "GitHub authorization state did not match. Please try again."
      return
    end

    access_token = Github::Client.new.exchange_code_for_access_token(
      code: params[:code],
      redirect_uri: github_auth_callback_url
    )

    session[:github_access_token] = access_token
    redirect_to redirect_path, notice: "GitHub authorization succeeded. Higher API limits are now available."
  rescue Github::Client::Error => error
    session.delete(:github_access_token)
    redirect_to redirect_path, alert: error.message
  end

  def destroy
    session.delete(:github_access_token)
    redirect_back_or_to compare_path, notice: "GitHub authorization removed for this browser session."
  end

  private

  def authorize_url(state)
    uri = URI("https://github.com/login/oauth/authorize")
    uri.query = URI.encode_www_form(
      client_id: ENV.fetch("GITHUB_CLIENT_ID"),
      redirect_uri: github_auth_callback_url,
      scope: "",
      state: state
    )
    uri.to_s
  end

  def redirect_path
    session.delete(OAUTH_REDIRECT_PATH_KEY).presence || compare_path
  end

  def request_query_params
    params.permit(:repo, :from, :to).to_h.compact_blank
  end
end

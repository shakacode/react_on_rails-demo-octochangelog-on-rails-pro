class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :github_authenticated?, :github_auth_configured?

  private

  def github_access_token
    session[:github_access_token]
  end

  def github_authenticated?
    github_access_token.present?
  end

  def github_auth_configured?
    ENV["GITHUB_CLIENT_ID"].present? && ENV["GITHUB_CLIENT_SECRET"].present?
  end
end

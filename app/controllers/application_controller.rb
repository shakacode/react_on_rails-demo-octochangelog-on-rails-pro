class ApplicationController < ActionController::Base
  # Keep the browser baseline modern so the demo can lean on current CSS and JS features.
  allow_browser versions: :modern
end

class ApplicationController < ActionController::Base
  include AuthenticationHelpers

  allow_browser versions: :modern
end

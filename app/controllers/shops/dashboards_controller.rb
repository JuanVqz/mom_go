module Shops
  class DashboardsController < ApplicationController
    before_action :ensure_shop!
    before_action :require_authentication

    def show; end
  end
end

module FBScraper
  class ConfigurationsController < ApplicationController
    def show
    end

    def update
      session[:fb_scraper_browser] = params[:browser]
      session[:fb_scraper_facebook_username] = params[:facebook_username]
      session[:fb_scraper_facebook_password] = params[:facebook_password]

      redirect_to({action: :show}, notice: "Configuration updated.")
    end
  end
end

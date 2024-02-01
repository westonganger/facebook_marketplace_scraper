module FBScraper
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception

    def render_404
      if request.format.html?
        render "fb_scraper/exceptions/show", status: 404
      else
        render plain: "404 Not Found", status: 404
      end
    end

  end
end

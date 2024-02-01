Rails.application.routes.draw do
  mount FBScraper::Engine => "/"
end

require 'spec_helper'

RSpec.describe FBScraper::ConfigurationsController, type: :request do

  def create_search_item
    @search_item ||= FBScraper::ConfigurationItem.create!(search_text: "foo")
  end

  def create_post(**attrs)
    create_search_item

    @post = FBScraper::Post.create!(
      {
        title: "some-title",
        location: "some-location",
        url: "some-url",
        price: 1,
        search_item: @search_item,
      }.merge(attrs)
    )
  end

  context "show" do
    it "renders" do
      get "/configuration"
      expect(response.status).to eq(200)
    end
  end

  context "update" do
    it "works" do
      patch "/configuration", params: {
        browser: "Chrome",
        facebook_username: "foo",
        facebook_password: "bar",
      }
      expect(response.status).to eq(302)
      expect(response).to redirect_to("/configuration")
    end
  end

end

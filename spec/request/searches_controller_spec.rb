require 'spec_helper'

RSpec.describe FBScraper::SearchesController, type: :request do

  def create_search_item
    @search_item ||= FBScraper::SearchItem.create!(search_text: "foo")
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

  context "index" do
    it "renders an empty list" do
      get "/"
      expect(response.status).to eq(200)
    end

    it "renders a non-empty list" do
      create_search_item

      get "/searches/"
      expect(response.status).to eq(200)
    end

    context "search" do
      it "allows text" do
        create_search_item

        get "/searches/", params: {search: "not-found"}
        expect(response.status).to eq(200)
        expect(assigns(:searches)).to be_empty

        get "/searches/", params: {search: "foo"}
        expect(response.status).to eq(200)
        expect(assigns(:searches)).not_to be_empty
      end
    end
  end

  context "new" do
    it "renders" do
      get "/searches/new"
      expect(response.status).to eq(200)
    end
  end

  context "create" do
    it "works" do
      create_search_item

      expect(@search_item.search_text).to eq("foo")

      patch "/searches/#{@search_item.id}", params: {search_item: {search_text: "new-search"}}
      expect(response.status).to eq(302)
      expect(response).to redirect_to("/searches")

      @search_item.reload

      expect(@search_item.search_text).to eq("new-search")
    end
  end

  context "edit" do
    it "renders" do
      create_search_item

      get "/searches/#{@search_item.id}/edit"
      expect(response.status).to eq(200)
    end
  end

  context "update" do
    it "works" do
      create_search_item

      expect(@search_item.search_text).to eq("foo")

      patch "/searches/#{@search_item.id}", params: {search_item: {search_text: "new-search"}}
      expect(response.status).to eq(302)
      expect(response).to redirect_to("/searches")

      @search_item.reload

      expect(@search_item.search_text).to eq("new-search")
    end
  end

  context "destroy" do
    it "works" do
      create_search_item

      delete "/searches/#{@search_item.id}"
      expect(response.status).to eq(302)
      expect(response).to redirect_to("/searches")

      expect(FBScraper::SearchItem.find_by(id: @search_item.id)).to eq(nil)
    end
  end

end

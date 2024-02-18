require 'spec_helper'

RSpec.describe FBScraper::PostsController, type: :request do

  def create_search_item
    @search_item ||= FBScraper::SearchItem.create!(search_text: "foo")
  end

  def create_post(**attrs)
    create_search_item

    @post = FBScraper::Post.create!(
      {
        title: "some-title",
        location: "some-location",
        url: "some-url-#{SecureRandom.hex(3)}",
        price: 1,
        search_item: @search_item,
      }.merge(attrs)
    )
  end

  context "scrape" do
    it "redirects to config when credentials missing" do
      post "/listings/scrape"
      expect(response.status).to eq(302)
      expect(response).to redirect_to("/configuration")
    end
  end

  context "index" do
    it "renders an empty list" do
      get "/listings"
      expect(response.status).to eq(200)
    end

    it "renders a non-empty list" do
      create_post

      get "/"
      expect(response.status).to eq(200)
    end

    context "search" do
      it "allows text" do
        create_post

        get "/listings", params: {search: "foo"}
        expect(response.status).to eq(200)
        expect(assigns(:posts)).to be_empty

        get "/listings", params: {search: "some"}
        expect(response.status).to eq(200)
        expect(assigns(:posts)).not_to be_empty
      end

      it "allows min price" do
        create_post

        get "/listings", params: {min_price: "5"}
        expect(response.status).to eq(200)
        expect(assigns(:posts)).to be_empty

        get "/listings", params: {min_price: "1"}
        expect(response.status).to eq(200)
        expect(assigns(:posts)).not_to be_empty
      end

      it "allows max price" do
        create_post

        get "/listings", params: {max_price: "0"}
        expect(response.status).to eq(200)
        expect(assigns(:posts)).to be_empty

        get "/listings", params: {max_price: "1"}
        expect(response.status).to eq(200)
        expect(assigns(:posts)).not_to be_empty
      end

      it "allows search item selection" do
        create_post

        get "/listings", params: {search_item_id: "foo"}
        expect(response.status).to eq(200)
        expect(assigns(:posts)).to be_empty

        get "/listings", params: {search_item_id: @search_item.id}
        expect(response.status).to eq(200)
        expect(assigns(:posts)).not_to be_empty
      end
    end

    context "saved" do
      it "renders an empty list" do
        get "/listings", params: {saved: true}
        expect(response.status).to eq(200)
      end

      it "renders a non-empty list" do
        create_post

        get "/listings", params: {saved: true}
        expect(response.status).to eq(200)
      end
    end
  end

  context "update" do
    it "updates" do
      create_post

      expect(@post.read).to eq(false)
      expect(@post.saved).to eq(false)

      patch "/listings/#{@post.id}", params: {post: {read: true, saved: true}}
      expect(response.status).to eq(302)
      expect(response).to redirect_to("/listings")

      @post.reload

      expect(@post.read).to eq(true)
      expect(@post.saved).to eq(true)
    end
  end

  context "destroy" do
    it "destroys" do
      create_post

      delete "/listings/#{@post.id}"
      expect(response.status).to eq(302)
      expect(response).to redirect_to("/listings")

      expect(FBScraper::Post.find_by(id: @post.id)).to eq(nil)
    end
  end

  context "delete_all_unsaved" do
    it "destroys" do
      create_post(saved: true)
      create_post(saved: true)
      create_post
      create_post

      delete "/listings/delete_all_unsaved"
      expect(response.status).to eq(302)
      expect(response).to redirect_to("/listings")

      expect(FBScraper::Post.all.size).to eq(2)
    end
  end

end

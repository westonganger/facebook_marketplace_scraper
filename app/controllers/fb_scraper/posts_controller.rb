module FBScraper
  class PostsController < ApplicationController

    def index
      get_posts
    end

    def scrape
      @search_items = FBScraper::SearchItem.where(id: params.require(:search_item_ids))

      if @search_items.size == 0
        raise "error no search items found"
      end

      FBScraper::SearchItem.scrape_multiple!(@search_items)

      redirect_back(fallback_location: posts_path, notice: "Scrape successful")
    end

    def update
      @post = Post.find(params[:id])

      @post.update(params.require(:post).permit(:read, :saved))

      if request.format.html?
        if params[:redirect_to]
          redirect_to params[:redirect_to], notice: "Action was successfully performed."
        else
          redirect_back(fallback_location: posts_path, notice: "Action was successfully performed.")
        end
      else
        render json: @post
      end
    end

    def delete_all_unsaved
      get_posts

      @posts.unsaved.delete_all

      redirect_back(fallback_location: posts_path, notice: "All unsaved posts were successfully deleted.")
    end

    def destroy
      @post = FBScraper::Post.find(params[:id])
      @post.destroy
      redirect_back(fallback_location: posts_path, notice: "The post was successfuly deleted.")
    end

    private

    def get_posts
      @posts = Post.all

      @posts = @posts.order(created_at: :desc, title: :asc, price: :asc)

      if params[:saved].present?
        @title = "Saved Posts"
        @posts = @posts.saved
      else
        @title = "List"
      end

      if params[:search].present?
        @posts = @posts.where("title LIKE :search", search: "%#{params[:search]}%")
      end

      if params[:search_item_id].present?
        @posts = @posts.where(search_item_id: params[:search_item_id])
      end

      if params[:min_price].present?
        @posts = @posts.where("price >= ?", params[:min_price].to_i)
      end

      if params[:max_price].present?
        @posts = @posts.where("price <= ?", params[:max_price].to_i)
      end
    end

  end
end

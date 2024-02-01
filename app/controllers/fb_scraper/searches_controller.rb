module FBScraper
  class SearchesController < ApplicationController
    before_action :set_search, only: [:edit, :update, :destroy]

    def index
      @searches = FBScraper::SearchItem.all.order(search_text: :asc)

      if params[:search].present?
        @searches = @searches.where("search_text LIKE ?", "%#{params[:search]}%")
      end
    end

    def new
      @search = FBScraper::SearchItem.new
    end

    def edit
    end

    def create
      @search = FBScraper::SearchItem.new(_search_item_params)

      if @search.save
        redirect_to searches_path, notice: "Search was successfully created."
      else
        render :new
      end
    end

    def update
      if @search.update(_search_item_params)
        redirect_to searches_path, notice: "Search was successfully updated."
      else
        render :edit
      end
    end

    def destroy
      @search.destroy
      redirect_to searches_path, notice: "Search was successfully deleted."
    end

    private

    def set_search
      @search = FBScraper::SearchItem.find(params[:id])
    end

    def _search_item_params
      params.require(:search_item).permit(:search_text, :min_price, :max_price, :hidden_keywords)
    end
  end
end

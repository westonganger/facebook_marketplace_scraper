class AddFBScraperTables < ActiveRecord::Migration[6.0]
  def change
    create_table "fb_scraper_posts" do |t|
      t.string "title", null: false
      t.string "location"
      t.integer "price"
      t.string "url", null: false
      t.boolean "saved", default: false, null: false
      t.boolean "read", default: false, null: false
      t.integer "search_item_id", null: false
      t.index ["search_item_id"], name: "index_posts_on_search_item_id"
      t.timestamps
    end

    create_table "fb_scraper_search_items" do |t|
      t.string "search_text", null: false
      t.integer "min_price"
      t.integer "max_price"
      t.text "hidden_keywords"
      t.timestamps
    end
  end
end

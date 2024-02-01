module FBScraper
  class SearchItem < ApplicationRecord
    has_many :posts

    validates :search_text, presence: true
    validates :min_price, allow_blank: true, numericality: {greater_than_or_equal_to: 0}
    validates :max_price, allow_blank: true, numericality: {greater_than_or_equal_to: 0}
    validates :max_price, allow_blank: true, numericality: {greater_than_or_equal_to: :min_price}, if: :min_price

    before_save do
      if min_price&.zero?
        self.min_price = nil
      end

      if max_price&.zero?
        self.max_price = nil
      end

      if hidden_keywords.present?
        self[:hidden_keywords] = self[:hidden_keywords]
          .split(",")
          .map{|x| x.strip.presence }
          .compact
          .join(",")
      end
    end

    def hidden_keywords
      self[:hidden_keywords]&.split(",")
    end

    def price_range_str
      if min_price || max_price
        if min_price
          str = "$#{min_price}"
        else
          str = "$0"
        end

        if max_price
          str += " - $#{max_price}"
        else
          str += ' - Infinity'
        end
      else
        str = "Any Price"
      end
      return str.html_safe
    end

    def self.scrape_multiple!(search_items)
      Playwright.create(playwright_cli_executable_path: "./node_modules/.bin/playwright") do |playwright|
        browser = playwright.firefox.launch(headless: false)

        search_items.each do |search_item|
          search_item.scrape!(browser)
        end

        browser.close
      end

      return true
    end

    def scrape!(browser)
      page = browser.new_page

      login_url = "https://www.facebook.com/login/device-based/regular/login/"

      page.goto(login_url)

      Kernel.sleep(2) # Wait for the page to load.

      params = {
        query: search_item.search_text,
        minPrice: search_item.min_price,
        maxPrice: search_item.max_price,
        sortBy: "creation_time_descend",
      }.compact

      marketplace_url = "https://www.facebook.com/marketplace/category/search/?"

      marketplace_url << params.map{|k,v| "#{k}=#{v}" }.join("&")

      begin
        email_input = page
          .wait_for_selector('input[name="email"]')
          .fill('YOUR_EMAIL_HERE')

        password_input = page
          .wait_for_selector('input[name="pass"]')
          .fill('YOUR_PASSWORD_HERE')

        Kernel.sleep(2)

        login_button = page.wait_for_selector('button[name="login"]').click

        Kernel.sleep(2)
        page.goto(marketplace_url)
      rescue
        page.goto(marketplace_url)
      end

      Kernel.sleep(2) # Wait for the page to load.

      (1..5).each do
        # Infinite scroll to show more results
        page.keyboard.press("End")
        Kernel.sleep(2)
      end

      html = page.content

      doc = Nokogiri::HTML5(page.content)

      items = []

      doc.css("div.#{POST_CLASSES.gsub(" ", ".")}").each do |listing|
        title = listing
          .at_css("span.#{TITLE_CLASSES.gsub(" ", ".")}")
          .content

        price = listing
          .at_css("span.#{PRICE_CLASSES.gsub(" ", ".")}")
          .content
          .gsub(/\D/, "") # remove non-digit characters
          .to_i

        location = listing
          .at_css("span.#{LOCATION_CLASSES.gsub(" ", ".")}")
          .content

        url = listing
          .at_css("a.#{URL_CLASSES.gsub("", ".")}")
          .href

        next if search_item.hidden_keywords.any? do |bad|
          title&.include?(bad) || location&.downcase&.include?(bad)
        end

        # Append the parsed data to the list.
        items << {
          title: title,
          price: price,
          location: location,
          url: url,
        }
      end

      items = items.flatten.uniq{|x| x[:url] } # prevent duplicate items

      FBScraper::Post.upsert(items)
    end

  end
end

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

    def self.scrape_multiple!(search_items, browser_name, facebook_username, facebook_password)
      path = File.join(ENGINE_ROOT, "node_modules/.bin/playwright")

      Playwright.create(playwright_cli_executable_path: path) do |playwright|
        browser = playwright.send(browser_name).launch(headless: false)

        browser_page = browser.new_page

        fb_authenticate!(browser_page, facebook_username, facebook_password)

        search_items.each do |search_item|
          search_item.scrape!(browser_page)
        end

        browser.close
      end

      return true
    end

    def self.fb_authenticate!(browser_page, facebook_username, facebook_password)
      browser_page.goto("https://www.facebook.com/login/device-based/regular/login/")
      email_input = browser_page
        .wait_for_selector('input[name="email"]')
        .fill(facebook_username)
      password_input = browser_page
        .wait_for_selector('input[name="pass"]')
        .fill(facebook_password)
      login_button = browser_page
        .wait_for_selector('button[name="login"]')
        .click
    end

    def scrape!(browser_page)
      params = {
        query: search_text,
        minPrice: min_price,
        maxPrice: max_price,
        sortBy: "creation_time_descend",
      }.compact

      marketplace_url = "https://www.facebook.com/marketplace/category/search/?"

      marketplace_url << params.map{|k,v| "#{k}=#{v}" }.join("&")

      browser_page.goto(marketplace_url)
      #Kernel.sleep(1) # Wait for the page to load.

      (1..5).each do
        # Infinite scroll to show more results
        browser_page.keyboard.press("End")
        Kernel.sleep(1)
      end

      html = browser_page.content

      doc = Nokogiri::HTML5(browser_page.content)

      items = []

      doc.css("div.#{CLASSES.fetch(:post).gsub(" ", ".")}").each_with_index do |listing, index|
        #url_el = listing.at_css("a.#{CLASSES.fetch(:url).gsub(" ", ".")}")
        url_el = listing.at_css("a")
        if url_el.nil?
          next if index != 0
          raise "Error: Item URL element not found on page, please update the HTML class list in SearchItem"
        end
        url = url_el["href"]

        if !url.start_with?("/")
          # Ex. sponsored ads
          next
        end

        title_el = listing.at_css("span.#{CLASSES.fetch(:title).gsub(" ", ".")}")
        if title_el.nil?
          raise "Error: Title not found on page, please update the HTML class list in SearchItem"
        end
        title = title_el.content

        price_el = listing.at_css("span.#{CLASSES.fetch(:price).gsub(" ", ".")}")
        if price_el.nil?
          raise "Error: Price element not found on page, please update the HTML class list in SearchItem"
        end
        price = price_el
          .content
          .gsub(/\D/, "") # remove non-digit characters
          .to_i

        location_el = listing.at_css("span.#{CLASSES.fetch(:location).gsub(" ", ".")}")
        if location_el.nil?
          raise "Error: Item location element not found on page, please update the HTML class list in SearchItem"
        end
        location = location_el.content

        next if hidden_keywords.any? do |bad|
          title.include?(bad) || location.downcase&.include?(bad)
        end

        # Append the parsed data to the list.
        items << {
          title: title,
          price: price,
          location: location,
          url: url,
          search_item_id: self.id,
        }
      end

      items = items.flatten.uniq{|x| x[:url] } # prevent duplicate items

      FBScraper::Post.upsert_all(items)
    end

    CLASSES = {
      post: "x9f619 x78zum5 x1r8uery xdt5ytf x1iyjqo2 xs83m0k x1e558r4 x150jy0e x1iorvi4 xjkvuk6 xnpuxes x291uyu x1uepa24".freeze,

      title: "x1lliihq x6ikm8r x10wlt62 x1n2onr6".freeze,

      location: "x1lliihq x6ikm8r x10wlt62 x1n2onr6 xlyipyv xuxw1ft".freeze,

      price: "x193iq5w xeuugli x13faqbe x1vvkbs xlh3980 xvmahel x1n0sxbx x1lliihq x1s928wv xhkezso x1gmr53x x1cpjm7i x1fgarty x1943h6x x4zkp8e x676frb x1lkfr7t x1lbecb7 x1s688f xzsf02u".freeze,

      ### Deprecated, just use a[href] instead
      #url: "x1i10hfl xjbqb8w x1ejq31n xd10rxx x1sy0etr x17r0tee x972fbf xcfux6l x1qhh985 xm0m39n x9f619 x1ypdohk xt0psk2 xe8uvvx xdj266r x11i5rnm xat24cr x1mh8g0r xexx8yu x4uap5 x18d9i69 xkhd6sd x16tdsg8 x1hl2dhg xggy1nq x1a2a7pz x1heor9g x1lku1pv".freeze,
    }.freeze
  end
end

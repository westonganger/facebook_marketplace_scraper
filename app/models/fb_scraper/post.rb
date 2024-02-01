module FBScraper
  class Post < ApplicationRecord
    belongs_to :search_item

    ### No validations because we use upsert to add new records
    ### Heres what we expect anyways
    #validates :title, presence: true
    #validates :location, presence: true
    #validates :price, presence: true
    #validates :url, presence: true, uniqueness: true

    scope :recent, ->(){ where("created_at >= ?", 2.weeks.ago)}
    scope :old, ->(){ where("created_at < ?", 2.weeks.ago)}
    scope :saved, ->(){ where(saved: true)}
    scope :unsaved, ->(){ where.not(saved: true)}

    def self.delete_outdated!
      items = self.unsaved.where("created_at < ?", 60.days.ago)
      items.delete_all
    end

    POST_CLASSES = "x9f619 x78zum5 x1r8uery xdt5ytf x1iyjqo2 xs83m0k x1e558r4 x150jy0e x1iorvi4 xjkvuk6 xnpuxes x291uyu x1uepa24".freeze

    TITLE_CLASSES = "x1lliihq x6ikm8r x10wlt62 x1n2onr6".freeze

    LOCATION_CLASSES = "x1lliihq x6ikm8r x10wlt62 x1n2onr6 xlyipyv xuxw1ft".freeze

    PRICE_CLASSES = "x193iq5w xeuugli x13faqbe x1vvkbs xlh3980 xvmahel x1n0sxbx x1lliihq x1s928wv xhkezso x1gmr53x x1cpjm7i x1fgarty x1943h6x x4zkp8e x676frb x1lkfr7t x1lbecb7 x1s688f xzsf02u".freeze

    URL_CLASSES = "x1i10hfl xjbqb8w x6umtig x1b1mbwd xaqea5y xav7gou x9f619 x1ypdohk xt0psk2 xe8uvvx xdj266r x11i5rnm xat24cr x1mh8g0r xexx8yu x4uap5 x18d9i69 xkhd6sd x16tdsg8 x1hl2dhg xggy1nq x1a2a7pz x1heor9g x1lku1pv".freeze

  end
end

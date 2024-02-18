module FBScraper
  class Post < ApplicationRecord
    belongs_to :search_item

    ### No validations because we use upsert to add new records
    ### Heres what we expect anyways
    validates :title, presence: true
    validates :location, presence: true
    validates :price, presence: true
    validates :url, presence: true, uniqueness: true

    scope :recent, ->(){ where("created_at >= ?", 2.weeks.ago)}
    scope :old, ->(){ where("created_at < ?", 2.weeks.ago)}
    scope :saved, ->(){ where(saved: true)}
    scope :unsaved, ->(){ where.not(saved: true)}

    def self.delete_outdated!
      items = self.unsaved.where("created_at < ?", 60.days.ago)
      items.delete_all
    end
  end
end

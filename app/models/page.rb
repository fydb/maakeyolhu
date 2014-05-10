class Page < ActiveRecord::Base

  has_many :page_menu_mappings, dependent: :delete_all
  has_many :menus, through: :page_menu_mappings, uniq: true

  validates :name, :presence => true,
                   :uniqueness => true,
                   :length => { maximum: 250 }
  validates :permalink, :presence => true,
                        :length => { maximum: 250 },
                        :uniqueness => true
  validates :title, :length => { maximum: 250 }
  validates :meta_description,  :length => { maximum: 250 }

  scope :position_order, lambda { |num = 1| joins(:page_menu_mappings).where("page_menu_mappings.menu_id = ?", num).reorder("page_position").where(active: true) }


  default_scope order: "name ASC"
  after_save { Page.cache_expiration }
  after_destroy { Page.cache_expiration }

  include ActionView::Helpers::TextHelper # for using 'truncate' method on prettify_permalink
  before_validation :prettify_permalink

  def self.first_page
  homepage_id = Setting.where(meta_key: "homepage").first.meta_value
    where(id: homepage_id).first
  end

  def prettify_permalink
    if self.permalink.nil?
      self.permalink = ""
    else
      # parameterize function is nice but not as good as below
      self.permalink = truncate(self.permalink.strip.gsub(/[\~]|[\`]|[\!]|[\@]|[\#]|[\$]|[\%]|[\^]|[\&]|[\*]|[\(]|[\)]|[\+]|[\=]|[\{]|[\[]|[\}]|[\]]|[\|]|[\\]|[\:]|[\;]|[\"]|[\']|[\<]|[\,]|[\>]|[\.]|[\?]|[\/]/,"").gsub(/\s+/,"-").downcase, length: 50, separator: "-", omission: "")
    end
  end

  def self.cache_expiration
    Rails.cache.clear rescue ""
    immune_deletion_cache = ["404.html", "422.html", "500.html"]
    Dir["#{Rails.root}/public/*.html"].entries.each do |f|
      File.delete(f) unless immune_deletion_cache.include?(f.gsub("#{Rails.root}/public/", ""))
    end
  end
end

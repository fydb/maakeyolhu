class Menu < ActiveRecord::Base
  has_many :page_menu_mappings, dependent: :delete_all
  has_many :pages, through: :page_menu_mappings, uniq: true

  validates :name, :presence => true,
  			:uniqueness => true,
   			:length => { maximum: 250 }
end

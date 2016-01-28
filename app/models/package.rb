class Package < ActiveRecord::Base
  validates :name, :version, :date, :title, :description, :repository, :licence, :packaged, :publication, presence: true
end

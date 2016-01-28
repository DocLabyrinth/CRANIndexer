class Package < ActiveRecord::Base
  validates :name, :version, :date, :title, :description, :repository, :licence, :packaged, :publication, presence: true

  def self.from_dcf(dcf)
    ["Package", "Version"].each do |field|
      raise ArgumentError, "The dcf object must have a #{field} field" unless dcf[field]
    end

    package = Package.new
    package.name = dcf["Package"]
    package.version = dcf["Version"]
    package
  end
end

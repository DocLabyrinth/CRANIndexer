class Package < ActiveRecord::Base
  REPO_BASE_URL = "https://cran.r-project.org/src/contrib"

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

  def fetch_description!
    unless name && version
      raise ArgumentError, "name and version are required before fetching the package description"
    end

    Tempfile.open("cran-indexer-package-#{name}") do |f|
      f.binmode

      f.write(
        Net::HTTP.get_response(
          URI("#{REPO_BASE_URL}/#{name}_#{version}.tar.gz")
        ).body
      )
      f.rewind

      desc_dcf = Gem::Package::TarReader.new(
        Zlib::GzipReader.new(f)
      ).each_entry
        .find{|entry| /DESCRIPTION$/.match(entry.full_name)}
        .read

      desc_obj = Dcf.parse(desc_dcf).first

      self.title = desc_obj["Title"]
      self.description = desc_obj["Description"]
      self.repository = desc_obj["Repository"]
      self.licence = desc_obj["License"]

      self.packaged =  DateTime.parse(desc_obj["Packaged"], '%Y-%M-%d %H:%M:%S' )
      self.publication =  DateTime.parse(desc_obj["Date/Publication"], '%Y-%M-%d %H:%M:%S' )

      self.date = if desc_obj.include?("Date")
        DateTime.parse(desc_obj["Date"], '%Y-%M-%d' )
      else
        self.publication
      end
    end
  end
end

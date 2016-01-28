require "dcf"

namespace :cran do
  desc "Fetch the cran PACKAGES list from the default mirror"
  task :fetch_list do
    download_dir = File.join(File.dirname(__FILE__), "..", "..", "data")
    FileUtils.mkdir_p(download_dir)
    download_path =  File.join(download_dir, "PACKAGES")
    File.open(download_path, "w") do |f|
      Net::HTTP.get_response(
        URI("http://cran.r-project.org/src/contrib/PACKAGES")
      )
    end
  end

  desc "Import the CRAN packages into the database"
  task :import do

  end
end

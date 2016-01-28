describe Package do
  shared_examples "required string field" do |field|
    it "requires the #{field} field" do
      p = Package.new
      expect( p.valid? ).to eq(false)
      expect( p.errors[field.to_sym].first ).to eq("can't be blank")
      p.send("#{field}=", "test name")
      p.valid?
      expect( p.errors[field.to_sym].length ).to eq(0)
    end
  end

  shared_examples "required date field" do |field|
    it "requires the #{field} field" do
      p = Package.new
      expect( p.valid? ).to eq(false)
      expect( p.errors[field.to_sym].first ).to eq("can't be blank")
      p.send("#{field}=", DateTime.new(2015,1,1))
      p.valid?
      expect( p.errors[field.to_sym].length ).to eq(0)
    end
  end

  shared_examples "date field" do |field|
    it "accepts a valid date object" do
      p = Package.new
      p.send("#{field}=", DateTime.new(2015, 01, 01))
      p.valid?
      expect( p.errors[field.to_sym].length ).to eq(0)
    end

    it "rejects an unparsed date string" do
      p = Package.new
      p.send("#{field}=", "2015-01-01")
      p.valid?
      expect( p.errors[field.to_sym].length ).to eq(0)
    end
  end

  describe "validations" do
    describe "#name" do
      it_behaves_like "required string field", :name
    end

    describe "#version" do
      it_behaves_like "required string field", :version
    end

    describe "#date" do
      it_behaves_like "date field", :date
      it_behaves_like "required date field", :date
    end

    describe "#title" do
      it_behaves_like "required string field", :title
    end

    describe "#description" do
      it_behaves_like "required string field", :description
    end

    describe "#repository" do
      it_behaves_like "required string field", :repository
    end

    describe "#licence" do
      it_behaves_like "required string field", :licence
    end

    describe "#packaged" do
      it_behaves_like "date field", :packaged
      it_behaves_like "required date field", :packaged
    end

    describe "#publication" do
      it_behaves_like "date field", :publication
      it_behaves_like "required date field", :publication
    end
  end

  describe "Package#from_dcf" do
    it "returns a Package object with :name, :version filled in" do
      p = Package.from_dcf(dcf_hash)
      expect( p.name ).to eq("abc")
      expect( p.version ).to eq("2.1")
    end

    it "throws an ArgumentError if the Package field is missing" do
      expect do
        dcf = dcf_hash
        dcf["Package"] = nil
        Package.from_dcf(dcf)
      end.to raise_error(ArgumentError, "The dcf object must have a Package field")
    end

    it "throws an ArgumentError if the Version field is missing" do
      expect do
        dcf = dcf_hash
        dcf["Version"] = nil
        Package.from_dcf(dcf)
      end.to raise_error(ArgumentError, "The dcf object must have a Version field")
    end

    def dcf_hash
      {
        "Package"=>"abc",
        "Version"=>"2.1",
        "Depends"=>"R (>= 2.10), abc.data, nnet, quantreg, MASS, locfit",
        "License"=>"GPL (>= 3)",
        "NeedsCompilation"=>"no"
      }
    end
  end

  describe "#fetch_description!" do
    it "downloads the package to a temp file and extracts the description" do
      p = Package.new(:name => "bdrift", :version => "1.1.7")

      allow( Net::HTTP ).to receive(:get_response).with(
        URI("#{Package::REPO_BASE_URL}/#{p.name}_#{p.version}.tar.gz")
      ).and_return(OpenStruct.new(:body => fixture_gzip))

      p.fetch_description!

      desc = fixture_description_hash

      expect( p.title ).to eq(desc["Title"])

      # manually extracting the file and reading it through ruby give the same
      # results but one preserves stretches of whitespace, the other doesn't.
      # This is a quick workaround since the text itself is the same
      expect( p.description.gsub(/\s+/, " ") ).to eq( desc["Description"].gsub(/\s+/, " ") )

      expect( p.repository ).to eq(desc["Repository"])

      # FIXME: field is called licence, dcf has it spelt license, for now just map it
      expect( p.licence ).to eq(desc["License"])

      expect( p.date ).to eq( DateTime.parse(desc["Date"], '%Y-%M-%d') )
      expect( p.packaged ).to eq( DateTime.parse(desc["Packaged"], '%Y-%M-%d %H:%M:%S') )
      expect( p.publication ).to eq( DateTime.parse(desc["Date/Publication"], '%Y-%M-%d %H:%M:%S') )

      expect( p.valid? ).to eq(true)
    end

    # TODO: test when Date is not supplied

    describe "raises an ArgumentError" do
      it "if version is not present" do
        p = Package.new(:name => "bdrift")
        expect do
          p.fetch_description!
        end.to raise_error(ArgumentError, "name and version are required before fetching the package description")
      end

      it "if name is not present" do
        p = Package.new(:version => "1.1.7")
        expect do
          p.fetch_description!
        end.to raise_error(ArgumentError, "name and version are required before fetching the package description")
      end
    end

    def fixture_gzip
      path = File.join(File.dirname(__FILE__), "..", "..", "data", "bdrift_1.1.7.tar.gz")
      File.read(path)
    end

    def fixture_description_hash
      path = File.join(File.dirname(__FILE__), "..", "..", "data", "bdrift_description.dcf")
      Dcf.parse( File.read(path) ).first
    end
  end
end

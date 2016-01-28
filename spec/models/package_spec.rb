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
end

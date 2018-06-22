RSpec.describe PsUtilities do

  it "has a version number" do
    expect(PsUtilities::Version::VERSION).not_to be nil
  end

  it "has the correct version number" do
    expect(PsUtilities::Version::VERSION).to eq "0.3.1"
  end

end

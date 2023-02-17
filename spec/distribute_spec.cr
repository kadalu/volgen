require "spec"

require "../src/volgen"

DIST_TMPL         = File.read("templates/client.vol.j2")
DIST_VOLDATA_JSON = File.read("samples/distribute.json")

describe Volgen do
  context "Volfile generation of Distribute volumes" do
    it "checks if volfile rendered for distribute volume" do
      volfile = Volgen.generate(DIST_TMPL, DIST_VOLDATA_JSON)
      volfile.should eq File.read("spec/sample_output/distribute.vol")
    end
  end
end

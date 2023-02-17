require "spec"

require "../src/volgen"

DISPERSE_TMPL            = File.read("templates/client.vol.j2")
DISP_VOLDATA_JSON       = File.read("samples/disperse.json")
DIST_DISP_VOLDATA_JSON  = File.read("samples/dist_disperse.json")

describe Volgen do
  context "Volfile generation of Disperse volumes" do
    it "checks if volfile rendered for disperse volume" do
      volfile = Volgen.generate(DISPERSE_TMPL, DISP_VOLDATA_JSON)
      volfile.should eq File.read("spec/sample_output/disperse.vol")
    end

    it "checks if volfile rendered for distributed disperse volume" do
      volfile = Volgen.generate(DISPERSE_TMPL, DIST_DISP_VOLDATA_JSON)
      volfile.should eq File.read("spec/sample_output/dist_disperse.vol")
    end
  end
end

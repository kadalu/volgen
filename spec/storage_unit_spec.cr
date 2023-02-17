require "spec"

require "../src/volgen"

STORAGE_UNIT_TMPL            = File.read("templates/storage_unit.vol.j2")
STORAGE_UNIT_JSON       = File.read("samples/storage_unit.json")
STORAGE_UNIT_ARBITER_JSON       = File.read("samples/storage_unit_arbiter.json")

describe Volgen do
  context "Volfile generation of Storage Units" do
    it "checks if volfile rendered for regular storage unit" do
      volfile = Volgen.generate(STORAGE_UNIT_TMPL, STORAGE_UNIT_JSON)
      volfile.should eq File.read("spec/sample_output/storage_unit.vol")
    end

    it "checks if volfile rendered for arbiter storage unit" do
      volfile = Volgen.generate(STORAGE_UNIT_TMPL, STORAGE_UNIT_ARBITER_JSON)
      volfile.should eq File.read("spec/sample_output/storage_unit_arbiter.vol")
    end
  end
end

require "spec"

require "../src/volgen"

REPLICA_TMPL            = File.read("templates/client.vol.j2")
REP2_VOLDATA_JSON       = File.read("samples/replica2.json")
DIST_REP2_VOLDATA_JSON  = File.read("samples/dist_replica2.json")
REP3_VOLDATA_JSON       = File.read("samples/replica3.json")
DIST_REP3_VOLDATA_JSON  = File.read("samples/dist_replica3.json")
TIEBREAKER_VOLDATA_JSON = File.read("samples/tiebreaker.json")

describe Volgen do
  context "Volfile generation of Replica volumes" do
    it "checks if volfile rendered for replica2 volume" do
      volfile = Volgen.generate(REPLICA_TMPL, REP2_VOLDATA_JSON)
      volfile.should eq File.read("spec/sample_output/replica2.vol")
    end

    it "checks if volfile rendered for distributed replica2 volume" do
      volfile = Volgen.generate(REPLICA_TMPL, DIST_REP2_VOLDATA_JSON)
      volfile.should eq File.read("spec/sample_output/dist_replica2.vol")
    end

    it "checks if volfile rendered for Tiebreaker volume" do
      volfile = Volgen.generate(REPLICA_TMPL, TIEBREAKER_VOLDATA_JSON)
      volfile.should eq File.read("spec/sample_output/tiebreaker.vol")
    end

    it "checks if volfile rendered for replica3 volume" do
      volfile = Volgen.generate(REPLICA_TMPL, REP3_VOLDATA_JSON)
      volfile.should eq File.read("spec/sample_output/replica3.vol")
    end

    it "checks if volfile rendered for distributed replica3 volume" do
      volfile = Volgen.generate(REPLICA_TMPL, DIST_REP3_VOLDATA_JSON)
      volfile.should eq File.read("spec/sample_output/dist_replica3.vol")
    end
  end
end

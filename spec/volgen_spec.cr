require "spec"

require "../src/volgen"

describe Volgen do
  context "Volfile generation" do
    it "checks if volfile rendered without any variables" do
      volfile = Volgen.generate(<<-TMPL, "{}")
        name vol1
        type debug/io-stats
        TMPL
      volfile.should eq <<-OUTPUT
        volume vol1
            type debug/io-stats
        end-volume
        OUTPUT
    end

    it "checks if volfile rendered with variables" do
      data = %Q[{"name": "vol1", "id": "4197af87-e394-4917-a1d2-ecd08b1b588d"}]
      volfile = Volgen.generate(<<-TMPL, data)
        name {{ volume.name }}
        type debug/io-stats
        option volume-id {{ volume.id }}
        TMPL
      volfile.should eq <<-OUTPUT
        volume vol1
            type debug/io-stats
            option volume-id 4197af87-e394-4917-a1d2-ecd08b1b588d
        end-volume
        OUTPUT
    end

    it "checks if volfile rendered with auto subvolumes" do
      data = %Q[{"name": "vol1", "id": "4197af87-e394-4917-a1d2-ecd08b1b588d"}]
      volfile = Volgen.generate(<<-TMPL, data)
        name {{ volume.name }}-md-cache
        type performance/md-cache

        name {{ volume.name }}-io-threads
        type performance/io-threads

        name {{ volume.name }}
        type debug/io-stats
        option volume-id {{ volume.id }}
        TMPL
      volfile.should eq <<-OUTPUT
        volume vol1-md-cache
            type performance/md-cache
        end-volume

        volume vol1-io-threads
            type performance/io-threads
            subvolumes vol1-md-cache
        end-volume

        volume vol1
            type debug/io-stats
            option volume-id 4197af87-e394-4917-a1d2-ecd08b1b588d
            subvolumes vol1-io-threads
        end-volume
        OUTPUT
    end

    it "checks if volfile rendered with variables and options" do
      data = %Q[{"name": "vol1", "id": "4197af87-e394-4917-a1d2-ecd08b1b588d"}]
      opts = {"diagnostics.client-log-level" => "DEBUG"}
      volfile = Volgen.generate(<<-TMPL, data, opts)
        name {{ volume.name }}-client
        type protocol/client

        name {{ volume.name }}
        type debug/io-stats
        option volume-id {{ volume.id }}
        TMPL
      volfile.should eq <<-OUTPUT
        volume vol1-client
            type protocol/client
        end-volume

        volume vol1
            type debug/io-stats
            option volume-id 4197af87-e394-4917-a1d2-ecd08b1b588d
            option log-level DEBUG
            subvolumes vol1-client
        end-volume
        OUTPUT
    end

    it "checks if volfile rendered with auto subvolumes (When parent attr is set)" do
      data = %Q[{"name": "vol1", "id": "4197af87-e394-4917-a1d2-ecd08b1b588d"}]
      volfile = Volgen.generate(<<-TMPL, data)
        name {{ volume.name }}-md-cache
        type performance/md-cache
        parent {{ volume.name }}

        name {{ volume.name }}-io-threads
        type performance/io-threads
        parent {{ volume.name }}

        name {{ volume.name }}
        type debug/io-stats
        option volume-id {{ volume.id }}
        TMPL
      volfile.should eq <<-OUTPUT
        volume vol1-md-cache
            type performance/md-cache
        end-volume

        volume vol1-io-threads
            type performance/io-threads
        end-volume

        volume vol1
            type debug/io-stats
            option volume-id 4197af87-e394-4917-a1d2-ecd08b1b588d
            subvolumes vol1-md-cache vol1-io-threads
        end-volume
        OUTPUT
    end
  end
end

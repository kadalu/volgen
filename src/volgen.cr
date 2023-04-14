require "crinja"

require "./options"

module Volgen
  @[Crinja::Attributes]
  class TiebreakerData
    include Crinja::Object::Auto
    include JSON::Serializable
    property node = "", path = "", port = 0

    def initialize
    end
  end

  @[Crinja::Attributes]
  class Volume
    include Crinja::Object::Auto
    include JSON::Serializable

    property id = "", name = "", distribute_groups = [] of DistributeGroup, tiebreaker = TiebreakerData.new

    def distribute_groups_name
      names = @distribute_groups.map_with_index do |dist_grp, idx|
        "#{@name}-#{dist_grp.type}-#{idx}"
      end

      names.join(" ")
    end

    def initialize
    end
  end

  @[Crinja::Attributes]
  class Node
    include Crinja::Object::Auto
    include JSON::Serializable

    property name = "", id = ""

    def initialize
    end
  end

  @[Crinja::Attributes]
  class StorageUnit
    include Crinja::Object::Auto
    include JSON::Serializable

    property path = "", type = "", port = 0, index = -1, node = Node.new, volume = Volume.new
  end

  @[Crinja::Attributes]
  class DistributeGroup
    include Crinja::Object::Auto
    include JSON::Serializable

    property type = "", replica_count = 0, redundancy_count = 0, arbiter_count = 0, storage_units = [] of StorageUnit
  end

  class VolfileElement
    property name = "", type = "", options = Hash(String, String).new, subvolumes = "", parent = ""

    def initialize
    end
  end

  class Volfile
    property parsed_options = Options.new

    # Rendered Volfile is passed here to split into the elements
    #
    def initialize(@data : String, options : Hash(String, String))
      element = VolfileElement.new
      @elements = [] of VolfileElement

      @data.split("\n").each do |line|
        line = line.strip
        if line.starts_with?("name ")
          # One graph is complete. Start new graph parsing
          @elements << element if element.name != ""
          element = VolfileElement.new
          element.name = line.split[-1]
        elsif line.starts_with?("option ")
          _, name, value = line.split
          element.options[name] = value
        elsif line.starts_with?("subvolumes ")
          element.subvolumes = line.split(" ", 2)[-1]
        elsif line.starts_with?("type ")
          element.type = line.split[-1]
        elsif line.starts_with?("parent ")
          element.parent = line.split[-1]
        end
      end

      # Add the last element
      @elements << element

      @parsed_options = VolfileOptions.parsed_options(volfile_type, options, @elements)
      enable_disable_xlators
      update_subvolumes
      update_options_by_type
      update_options_by_name
    end

    # Check if the value says a option is disabled
    def option_value_disabled?(val)
      val == "off" || val == "disable" || val == "no" || val == "false"
    end

    # Enable or disable elements based on the
    # xlator_enabled field. Generate new elements
    # list with only enabled elements.
    def enable_disable_xlators
      tmp_elements = @elements
      @elements = [] of VolfileElement

      tmp_elements.each do |element|
        opts = @parsed_options[element.type]?
        next if opts && option_value_disabled?(opts.fetch("xlator_enabled", ""))

        @elements << element
      end
    end

    # To auto detect the type of volfile based on existence of
    # protocol client or server.
    def volfile_type
      @elements.each do |element|
        return "client" if element.type == "protocol/client"
        return "storage_unit" if element.type == "protocol/server"
      end

      "unknown"
    end

    # Valid list of xlators that can become child of cluster/dht xlator
    def under_dht?(element)
      ["cluster/replicate", "cluster/disperse"].includes?(element.type)
    end

    # Intelligent subvolumes updator.
    # 1. If specified in the template itself - Do not modify
    # 2. If any elements parent field matches the current element name
    # 3. If current element is replicate and any element before this has
    #    a name that ends with `-ta` (Thin arbiter).
    # 4. If the current element is DHT and any previous elements are child
    #    of DHT (Ex: replicate, disperse)
    # 5. If no subvols detected then add previous element as child of
    #    current element. That is, add to subvols list. (Only if parent is
    #    not specified in the previous element)
    def update_subvolumes
      @elements.each_with_index do |element, idx|
        next if element.type == "protocol/client"
        next if idx == 0

        # If specified by the template then don't modify
        next unless element.subvolumes == ""

        subvols = [] of String
        (0...idx).each do |i|
          # If current element is DHT then find all child elements
          # Or if the graph name starts with the current name
          if @elements[i].parent == element.name ||
             (element.type == "cluster/replicate" && @elements[i].name.ends_with?("-ta")) ||
             (element.type == "cluster/distribute" && under_dht?(@elements[i]))
            subvols << @elements[i].name
          end
        end

        # If no subvolumes identified, then add the
        # previous element as subvolume if parent is not specified
        if subvols.size == 0 && @elements[idx - 1].parent == ""
          subvols << @elements[idx - 1].name
        end

        element.subvolumes = subvols.join(" ")
      end
    end

    # Add or update the options for each elements
    # if the user provided options for that type.
    def update_options_by_type
      @elements.each do |element|
        opts = @parsed_options[element.type]?
        element.options.merge!(opts) if opts
      end
    end

    def update_options_by_name
      @elements.each do |element|
        opts = @parsed_options[element.name]?
        element.options.merge!(opts) if opts
      end
    end

    # Generate the final Volfile based on all the parsed details
    # Sample:
    # ```
    # volume storage-pool-1
    #     type debug/io-stats
    #     option volume-id 974eaef2-bca9-11ed-9d23-0242ac110003
    #     subvolumes storage-pool-1-io-threads
    # end-volume
    # ```
    def generate
      content = String::Builder.new
      @elements.each do |element|
        content << "volume #{element.name}\n"
        content << "    type #{element.type}\n"
        element.options.each do |key, value|
          next if key == "xlator_enabled"

          content << "    option #{key} #{value}\n"
        end
        content << "    subvolumes #{element.subvolumes}\n" unless element.subvolumes == ""
        content << "end-volume\n\n"
      end

      content.to_s.strip
    end
  end

  # Volfile.generate generates the volfile using the given
  # template and data. Automatically detect the type of
  # data as Volume or StorageUnit type.
  def self.generate(tmpl, raw_data)
    generate(tmpl, raw_data, Hash(String, String).new)
  end

  # Generate Volfile using the given template, data and options
  def self.generate(tmpl, raw_data, options : Hash(String, String))
    env = Crinja.new
    template = env.from_string(tmpl)

    data = template_data(raw_data)

    # Render the Jinja template by giving the data
    rendered = case data
               when Volume      then template.render({"volume" => data})
               when StorageUnit then template.render({"storage_unit" => data})
               else                  template.render
               end

    volfile = Volfile.new rendered, options
    volfile.generate
  end

  # Try to automatically detect the data as volume
  # info or storage unit info. If the field "path"
  # exists then it must be a Storage unit since volume
  # doesn't contain the path.
  def self.template_data(raw_data)
    data = StorageUnit.from_json(raw_data)
    return data unless data.path == ""

    data = Volume.from_json(raw_data)
    return data unless data.name == ""

    nil
  end
end

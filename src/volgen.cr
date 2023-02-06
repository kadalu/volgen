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

    property path = "", port = 0, index = -1, node = Node.new, volume = Volume.new
  end

  @[Crinja::Attributes]
  class DistributeGroup
    include Crinja::Object::Auto
    include JSON::Serializable

    property type = "", storage_units = [] of StorageUnit
  end

  class VolfileElement
    property name = "", type = "", options = Hash(String, String).new, subvolumes = ""

    def initialize
    end
  end

  class Volfile
    property parsed_options = Options.new

    def initialize(@data : String, options : Hash(String, String))
      puts @data
      element = VolfileElement.new
      @elements = [] of VolfileElement

      @data.split("\n").each do |line|
        line = line.strip
        if line.starts_with?("volume ")
          element = VolfileElement.new
          element.name = line.split[-1]
        elsif line == "end-volume"
          @elements << element
        elsif line.starts_with?("option ")
          _, name, value = line.split
          element.options[name] = value
        elsif line.starts_with?("subvolumes ")
          element.subvolumes = line.split(" ", 2)[-1]
        elsif line.starts_with?("type ")
          element.type = line.split[-1]
        end
      end

      @parsed_options = VolfileOptions.parsed_options(volfile_type, options)
      enable_disable_xlators
      update_subvolumes
      update_options_by_type
      update_options_by_name
    end

    def option_value_disabled?(val)
      val == "off" || val == "disable"
    end

    def enable_disable_xlators
      tmp_elements = @elements
      @elements = [] of VolfileElement

      tmp_elements.each do |element|
        opts = @parsed_options[element.type]?
        next if opts && option_value_disabled?(opts.fetch("xlator_enabled", ""))

        @elements << element
      end
    end

    def volfile_type
      @elements.each do |element|
        return "client" if element.type == "protocol/client"
        return "storage-unit" if element.type == "protocol/server"
      end

      "unknown"
    end

    def under_dht?(element)
      ["cluster/replicate", "cluster/disperse"].includes?(element.type)
    end

    def update_subvolumes
      @elements.each_with_index do |element, idx|
        next if element.type == "protocol/client"
        next if idx == 0

        # If specified by the template then don't modify
        next unless element.subvolumes == ""

        # If it is last element then add the previous
        # element as subvolumes
        if idx == (@elements.size - 1)
          element.subvolumes = @elements[idx - 1].name
          next
        end

        subvols = [] of String
        (0...idx).each do |i|
          # If current element is DHT then find all child elements
          # Or if the graph name starts with the current name
          if @elements[i].name.starts_with?(element.name) ||
             (element.type == "cluster/replicate" && @elements[i].name.ends_with?("-ta")) ||
             (element.type == "cluster/distribute" && under_dht?(@elements[i]))
            subvols << @elements[i].name
          end
        end

        # If no subvolumes identified, then add the
        # previous element as subvolume.
        subvols << @elements[idx - 1].name if subvols.size == 0

        element.subvolumes = subvols.join(" ")
      end
    end

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

      content.to_s
    end
  end

  def self.generate(tmpl, raw_data)
    generate(tmpl, raw_data, Hash(String, String).new)
  end

  def self.generate(tmpl, raw_data, options : Hash(String, String))
    env = Crinja.new
    template = env.from_string(tmpl)

    data = template_data(raw_data)

    rendered = case data
               when Volume      then template.render({"volume" => data})
               when StorageUnit then template.render({"storage_unit" => data})
               else                  template.render
               end

    volfile = Volfile.new rendered, options
    volfile.generate
  end

  def self.template_data(raw_data)
    data = StorageUnit.from_json(raw_data)
    return data unless data.path == ""

    data = Volume.from_json(raw_data)
    return data unless data.name == ""

    nil
  end
end

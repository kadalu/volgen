require "./helpers"
require "./supported_options"

alias Options = Hash(String, Hash(String, String))

module VolfileOptions
  def self.valid_option?(volume, option_name, option_value)
    opt_conf = @@options_map[option_name]?
    raise InvalidOption.new("Invalid Option name: #{option_name}") unless opt_conf

    if opt_conf.allowed_values.size > 0
      found = opt_conf.allowed_values.includes?(option_value.downcase)
      unless found
        raise InvalidOption.new(
          "Invalid Option value: #{option_name}=#{option_value}. Choices: #{opt_conf.allowed_values.join(",")}"
        )
      end

      return found
    end

    # TODO: Other validations
    true
  end

  def self.parsed_option(volfile_type, option_name, option_value)
    opt_conf = @@options_map[option_name]?
    return Options.new unless opt_conf
    return Options.new unless opt_conf.type == "" || opt_conf.type == volfile_type

    # If option name is empty in the configuration
    # then it is not used as option within the graph.
    # Instead, use that to enable or disable the xlator
    if opt_conf.name == ""
      return {
        opt_conf.xlator => {
          "xlator_enabled" => option_value,
        },
      }
    end

    {
      opt_conf.xlator => {
        opt_conf.name => option_value,
      },
    }
  end

  def self.parsed_options(volfile_type, options)
    parsed = Options.new
    options.each do |key, value|
      parsed.merge!(parsed_option(volfile_type, key, value))
    end
    parsed
  end
end

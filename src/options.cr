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

  # Search each volfile elements to see if atleast one xlator
  # exists with the given name
  def self.xlator_name_exists?(elements, xlator_name)
    elements.each do |element|
      return true if element.name == xlator_name
    end

    false
  end

  # Search each volfile elements to see if atleast one xlator
  # exists with the given type
  def self.xlator_type_exists?(elements, xlator_type)
    elements.each do |element|
      return true if element.type == xlator_type
    end

    false
  end

  def self.parsed_option(volfile_type, option_name, option_value, elements)
    opt_conf = @@options_map[option_name]?

    # option is not found in the supported list of options.
    # It may be possible that use might have given the option
    # directly by giving the xlator name or by giving the name that
    # will be used to represent in the Volfile. For example,
    # debug/io-stats.log-level=debug  OR
    # /exports/pool1/s1.log-level=debug to apply this setting only for
    # the storage unit that contains the path `/exports/pool1/s1`
    # ```
    # volume /exports/pool1/s1
    #     type debug/io-stats
    #     option log-level debug
    #     subvolumes pool1-index
    # end-volume
    # ```
    unless opt_conf
      xlator_or_name, _sep, opt = option_name.partition(".")
      return Options.new if opt == ""

      if xlator_name_exists?(elements, xlator_or_name) || xlator_type_exists?(elements, xlator_or_name)
        return {
          xlator_or_name => {
            opt => option_value,
          },
        }
      end

      return Options.new
    end

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

  def self.parsed_options(volfile_type, options, elements)
    parsed = Options.new
    options.each do |key, value|
      parsed.merge!(parsed_option(volfile_type, key, value, elements))
    end
    parsed
  end
end

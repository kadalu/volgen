module VolfileOptions
  class_property options_map = Hash(String, OptionConfig).new

  class OptionConfig
    property type = "", name = "", allowed_values = [] of String, xlator = ""
  end

  class InvalidOption < Exception
  end

  def self.option_config(name : String, &block : OptionConfig -> Nil)
    opt = OptionConfig.new
    block.call(opt)
    @@options_map[name] = opt
  end

  def self.option_config(names : Array(String), &block : OptionConfig -> Nil)
    names.each do |name|
      opt = OptionConfig.new
      block.call(opt)
      @@options_map[name] = opt
    end
  end
end

require "option_parser"

require "crinja"

require "./volgen"

# Set VERSION during build time
VERSION = {{ env("VERSION") && env("VERSION") != "" ? env("VERSION") : `git describe --always --tags --match "[0-9]*" --dirty`.chomp.stringify }}

struct Args
  property template_file = "", data_file = "", options_file = "", output_file = ""
end

args = Args.new

OptionParser.parse do |parser|
  parser.banner = "Usage: kadalu-volgen [arguments]"
  parser.on("-t TEMPLATE", "--template=TEMPLATE", "Template file") { |f| args.template_file = f }
  parser.on("-d DATA_FILE", "--data=DATA_FILE", "Data file") { |f| args.data_file = f }
  parser.on("-c OPTIONS_FILE", "--options=OPTIONS_FILE", "Options file") { |f| args.options_file = f }
  parser.on("-o OUTPUT_FILE", "--output=OUTPUT_FILE", "Output file") { |f| args.output_file = f }
  parser.on("-h", "--help", "Show this help") do
    puts parser
    exit
  end
  parser.on("--version", "Show version information") do
    puts "Kadalu Volgen #{VERSION}"
    exit
  end
  parser.invalid_option do |flag|
    STDERR.puts "ERROR: #{flag} is not a valid option."
    STDERR.puts parser
    exit(1)
  end
end

volfile = if args.options_file == ""
            Volgen.generate(
              File.read(args.template_file),
              File.read(args.data_file)
            )
          else
            opts_data = File.read(args.options_file)
            opts = Hash(String, String).new
            opts_data.split("\n").each do |line|
              next if line.strip == ""

              key, value = line.strip.split("=", 2)
              opts[key] = value
            end

            Volgen.generate(
              File.read(args.template_file),
              File.read(args.data_file),
              opts
            )
          end

if args.output_file == ""
  puts volfile
else
  Dir.mkdir_p(Path[args.output_file].parent)
  File.write(args.output_file, volfile)
end

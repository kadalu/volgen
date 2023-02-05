require "option_parser"

require "crinja"

require "./volgen"

struct Args
  property template_file = "", data_file = "", options_file = "", output_file = ""
end

args = Args.new

OptionParser.parse do |parser|
  parser.banner = "Usage: kadalu-volgen [arguments]"
  parser.on("-t TEMPLATE", "--template=TEMPLATE", "Template file") { |f| args.template_file = f}
  parser.on("-d DATA_FILE", "--data=DATA_FILE", "Data file") { |f| args.data_file = f}
  parser.on("-c OPTIONS_FILE", "--options=OPTIONS_FILE", "Options file") { |f| args.options_file = f}
  parser.on("-o OUTPUT_FILE", "--output=OUTPUT_FILE", "Output file") { |f| args.output_file = f}
  parser.on("-h", "--help", "Show this help") do
    puts parser
    exit
  end
  parser.invalid_option do |flag|
    STDERR.puts "ERROR: #{flag} is not a valid option."
    STDERR.puts parser
    exit(1)
  end
end

puts args

volfile = if args.options_file == ""
            Volgen.generate(
              File.read(args.template_file),
              File.read(args.data_file)
            )
          else
            opts = Volgen::Options.from_json(File.read(args.options_file))
            Volgen.generate(
              File.read(args.template_file),
              File.read(args.data_file),
              opts
            )
          end

if args.output_file == ""
  puts volfile
else
  File.write(args.output_file, volfile)
end

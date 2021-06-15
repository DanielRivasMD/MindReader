################################################################################

import ArgParse: ArgParseSettings, @add_arg_table!, parse_args

################################################################################

function shArgParser(args)
  # minimal argument parsing
  s = ArgParseSettings(description = "MindReader command line utility.")
  @add_arg_table! s begin
      "--file", "-f"
        arg_type            = String
        required            = true
        help                = "`edf` file to read"
      "--indir", "-i"
        arg_type            = String
        required            = true
        help                = "`edf` file directory"
      "--outdir", "-o"
        arg_type            = String
        required            = false
        default             = "."
        help                = "output directory"
      "--outsvg", "-s"
        arg_type            = String
        required            = false
        help                = "output directory svg. Defined as `file`.svg at `outdir` if not specified"
      "--outcsv", "-c"
        arg_type            = String
        required            = false
        help                = "output directory csv. Defined as `file`.csv at `outdir` if not specified"
      "--window-size", "-w"
        nargs               = '?'
        arg_type            = Int
        default             = 256
        help                = "window size along raw signal"
      "--bin-overlap", "-b"
        nargs               = '?'
        arg_type            = Int
        default             = 4
        help                = "bin overlap along raw signal"
  end
  parsed_args = parse_args(s)
  return parsed_args
end

################################################################################

#  parse shell arguments
shArgs = shArgParser(ARGS)

################################################################################

# create directory if does not exist
if !isdir(shArgs["outdir"]) && shArgs["outdir"] != "."
  @info "Creating directory `$(shArgs["outdir"])`"
  mkdir(shArgs["outdir"])
end

################################################################################

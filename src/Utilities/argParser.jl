################################################################################

using ArgParse

################################################################################

function shArgParser(args)
  # minimal argument parsing
  s = ArgParseSettings(description = "mind reader")
  @add_arg_table! s begin
      "--file", "-f"
        arg_type            = String
        #  required            = true
        help                = "`edf` file to read"
      "--outdir", "-o"
        arg_type            = String
        required            = false
        help                = "output directory"
      "--fft", "-t"
        nargs               = '?'
        arg_type            = Int
        default             = 16
        help                = "number of frequencies for Fourier transform"
      "--window-size", "-w"
        nargs               = '?'
        arg_type            = Int
        default             = 128
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

begin
  file    = shArgs["file"]
  outdir  = shArgs["outdir"]
  fftBin  = shArgs["fft"]
  winBin  = shArgs["window-size"]
  overlap = shArgs["bin-overlap"]
end

################################################################################


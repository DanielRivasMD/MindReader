################################################################################

using MindReader
using HiddenMarkovModelReaders

################################################################################

# argument parser
include( "Utilities/argParser.jl" );

################################################################################

# read parameters
include( "Parameters.jl");

################################################################################

# read data
begin
  # read edf file
  edfDf, startTime, recordFreq = getSignals( string(shArgs["indir"], shArgs["file"]) )

  # calculate fft
  freqDc = extractChannelFFT(edfDf, binSize = shArgs["window-size"], binOverlap = shArgs["bin-overlap"])
end;

################################################################################

# build autoencoder & train hidden Markov model
begin

  errDc = Dict{String, Tuple{Array{Int64, 1}, Array{Array{Float64, 1}, 1}}}()

  for (k, f) in freqDc
    println()
    @info k

    #  build & train autoencoder
    freqAr = shifter(f)
    # model = buildAutoencoder(length(freqAr[1]), 100, Params)
    model = buildAutoencoder(length(freqAr[1]), 100, Params)
    model = modelTrain(freqAr, model, Params)

    ################################################################################

    postAr = Flux.cpu(model).(freqAr)

    ################################################################################

    begin
      @info "Creating Hidden Markov Model..."
      # error
      aErr = reshifter(postAr - freqAr) |> p -> Flux.flatten(p) |> permutedims

      # setup
      hmm = setup!(aErr)

      # process
      for i in 1:4
        errDc[k] = process!(hmm, aErr, true, params = hmmParams)
      end

      # final
      for i in 1:2
        errDc[k] = process!(hmm, aErr, false, params = hmmParams)
      end
    end;

    ################################################################################

  end
end;

################################################################################

# runHeatmap(outimg, outsvg, outcsv, errDc)
# runHeatmap(shArgs, errDc)

################################################################################

writeHMM( string(shArgs["outdir"], replace(shArgs["file"], ".edf" => "_")), errDc)

################################################################################

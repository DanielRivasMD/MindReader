################################################################################

using MindReader
using HiddenMarkovModelReaders

################################################################################

import Flux: cpu, gpu, flatten, leakyrelu

################################################################################

import Parameters: @with_kw

################################################################################

# read parameters
include( "Parameters.jl");

################################################################################

# argument parser
include( "Utilities/argParser.jl" );

################################################################################

# read data
begin
  # read edf file
  edfDf, _, _ = getSignals(shArgs)

  # calculate fft
  freqDc = extractFFT(edfDf, shArgs)
end;

################################################################################

# build autoencoder & train hidden Markov model
begin

  errDc = Dict{String, Tuple{Array{Int64, 1}, Array{Array{Float64, 1}, 1}}}()

  for (κ, υ) ∈ freqDc
    println()
    @info κ

    #  build & train autoencoder
    freqAr = shifter(υ)
    model = buildAutoencoder(length(freqAr[1]), nnParams = NNParams)
    model = modelTrain!(model, freqAr, nnParams = NNParams)

    ################################################################################

    postAr = cpu(model).(freqAr)

    ################################################################################

    begin
      @info "Creating Hidden Markov Model..."
      # error
      aErr = reshifter(postAr - freqAr) |> π -> flatten(π) |> permutedims

      # setup
      hmm = setup(aErr)

      # process
      for _ ∈ 1:4
        errDc[κ] = process!(hmm, aErr, true, params = hmmParams)
      end

      # final
      for _ ∈ 1:2
        errDc[κ] = process!(hmm, aErr, false, params = hmmParams)
      end
    end;

    ################################################################################

  end
end;

################################################################################

# write traceback & states
writeHMM( string(shArgs["outdir"], replace(shArgs["file"], ".edf" => "_")), errDc)

################################################################################

# graphic rendering
mindGraphics(errDc, shArgs)

################################################################################

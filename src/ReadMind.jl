################################################################################

# load packages
begin
  using MindReader
  using HiddenMarkovModelReaders

  using DelimitedFiles
end;

################################################################################

# import flux
import Flux: cpu, gpu, flatten, leakyrelu

################################################################################

# import parameters
import Parameters: @with_kw

################################################################################

# argument parser
include("Utilities/argParser.jl");

################################################################################

# load parameters
include(
  string(
    shArgs["paramsDir"],
    shArgs["params"],
  )
)

################################################################################

# include additional protocols
if haskey(shArgs, "additional") && haskey(shArgs, "addDir")
  for ι in split(shArgs["additional"], ",")
    include(
      string(
        shArgs["addDir"],
        ι,
      )
    )
  end
end

################################################################################

# read annotation
if haskey(shArgs, "annotation") && haskey(shArgs, "annotDir")
  annotFile = annotationReader(
    string(
      shArgs["annotDir"],
      shArgs["annotation"],
    )
  )
end

################################################################################

#  read data
begin
  # read edf file
  edfDf, startTime, recordFreq = getSignals(shArgs)

  # calculate fft
  freqDc = extractFFT(edfDf, shArgs)

  # calibrate annotations
  if haskey(annotFile, replace(shArgs["input"], ".edf" => ""))
    labelAr = annotationCalibrator(
      annotFile[replace(shArgs["input"], ".edf" => "")];
      startTime = startTime,
      recordFreq = recordFreq,
      signalLength = size(edfDf, 1),
      shParams = shArgs,
    )
  end
end;

################################################################################

# build autoencoder & train hidden Markov model
begin

  # create empty dictionary
  hmmDc = Dict{String, HMM}()

  # for (κ, υ) in freqDc
  begin
    κ = "P8-O2"
    υ = freqDc[κ]

    println()
    @info κ

    #  build & train autoencoder
    freqAr = shifter(υ)
    model = buildAutoencoder(length(freqAr[1]); nnParams = NNParams)
    model = modelTrain!(model, freqAr; nnParams = NNParams)

    ################################################################################

    # calculate post autoencoder
    postAr = cpu(model).(freqAr)

    # autoencoder error
    aErr = reshifter(postAr - freqAr) |> π -> flatten(π) |> π -> permutedims(π)

    ################################################################################

    begin
      # TODO: add hmm iteration settings
      @info "Creating Hidden Markov Model..."

      @info aErr
      # setup
      hmm = setup(aErr)

      # process
      for _ in 1:4
        process!(hmm, aErr, true; params=hmmParams)
      end

      # final
      for _ in 1:2
        process!(hmm, aErr, false; params=hmmParams)
      end

      # record hidden Markov model
      hmmDc[κ] = hmm
    end

    ################################################################################

  end

  print()
end;

################################################################################

# write traceback & states
writeHMM(hmmDc, shArgs)

################################################################################

if haskey(annotFile, replace(shArgs["input"], ".edf" => ""))
  writedlm(
    string(
      shArgs["outDir"],
      "screen/",
      replace(shArgs["input"], "edf" => "csv")
    ),
    writePerformance(sensitivitySpecificity(hmmDc, labelAr)),
    ", ",
  )

  ################################################################################

  # # graphic rendering
  # mindGraphics(hmmDc, shArgs, labelAr)

else

  # # graphic rendering
  # mindGraphics(hmmDc, shArgs)

end

################################################################################



# ################################################################################

# # read data
# begin
#   # read edf file
#   edfDf, _, _ = getSignals(shArgs)

#   # calculate fft
#   freqDc = extractFFT(edfDf, shArgs)
# end;

# ################################################################################

# # build autoencoder & train hidden Markov model
# begin

#   errDc = Dict{String, Tuple{Array{Int64, 1}, Array{Array{Float64, 1}, 1}}}()

#   for (κ, υ) ∈ freqDc
#     println()
#     @info κ

#     #  build & train autoencoder
#     freqAr = shifter(υ)
#     model = buildAutoencoder(length(freqAr[1]), nnParams = NNParams)
#     model = modelTrain!(model, freqAr, nnParams = NNParams)

#     ################################################################################

#     # calculate post autoencoder
#     postAr = cpu(model).(freqAr)

#     ################################################################################

#     begin
#       @info "Creating Hidden Markov Model..."
#       # error
#       aErr = reshifter(postAr - freqAr) |> π -> flatten(π) |> permutedims

#       # setup
#       hmm = setup(aErr)

#       # process
#       for _ ∈ 1:4
#         errDc[κ] = process!(hmm, aErr, true, params = hmmParams)
#       end

#       # final
#       for _ ∈ 1:2
#         errDc[κ] = process!(hmm, aErr, false, params = hmmParams)
#       end
#     end;

#     ################################################################################

#   end

#   println()

# end;

# ################################################################################

# # write traceback & states
# writeHMM(errDc, shArgs)

# ################################################################################

# # graphic rendering
# mindGraphics(errDc, shArgs)

# ################################################################################

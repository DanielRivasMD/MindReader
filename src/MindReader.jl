################################################################################

module MindReader

################################################################################

import Pkg: activate
activate("../")

################################################################################

#  argument parser
include( "Utilities/argParser.jl" );

################################################################################


#  declare tool directories
utilDir    = "Utilities/"
signalDir  = "SignalProcessing/"
arqDir     = "Architect/"
hmmDir     = "HiddenMarkovModel/"
graphDir   = "Graphics/"

################################################################################

#  load functions
@info("Loading modules...")
include( string(utilDir,    "fileReaderEDF.jl") );
include( string(utilDir,    "electrodeID.jl") );
# include( string(utilDir,    "fileReaderXLSX.jl") );
include( string(signalDir,  "signalBin.jl") );
include( string(signalDir,  "fastFourierTransform.jl") );
include( string(hmmDir,     "hiddenMarkovModel.jl") );
include( string(arqDir,     "architect.jl") );
include( string(arqDir,     "shapeShifter.jl") );
include( string(arqDir,     "autoencoder.jl") );
include( string(graphDir,   "statesHeatMap.jl") );

################################################################################

import Parameters: @with_kw

# set hyperparameters
@with_kw mutable struct Params
  η::Float64 = 1e-3                               # learning rate
  epochs::Int = 10                                # number of epochs
  batchsize::Int = 1000                           # batch size for training
  throttle::Int = 5                               # throttle timeout
  device::Function = gpu                          # set as gpu, if gpu available
end

################################################################################

# read edf file
edfDf, startTime, recordFreq = getSignals(file)

# calculate fft
freqDc = extractChannelFFT(edfDf, binSize = winBin, binOverlap = overlap)

################################################################################

for d in [Symbol(i, "Dc") for i = [:err, :post, :comp]]
  @eval $d = Dict{String, Tuple{Array{Int64, 1}, Array{Array{Float64, 1}, 1}}}()
end

for (k, f) in freqDc
  println()
  @info k
  #  build & train autoencoder
  freqAr = shifter(f)
  model = buildDeepRecurrentAutoencoder(length(freqAr[1]), 100, leakyrelu)
  # model = buildRecurrentAutoencoder(length(freqAr[1]), 100, leakyrelu)
  # model = buildAutoencoder(length(freqAr[1]), 100, leakyrelu)
  model = modelTrain(freqAr, model, Params)

  ################################################################################

  #  # post
  postAr = cpu(model).(freqAr)
  #  aPos = reshifter(postAr) |> p -> Flux.flatten(p)
  #
  #  # setup
  #  mPen, hmm = setup(aPos)
  #  # process
  #  for i in 1:5
  #    postDc[k] = process(hmm, aPos, mPen)
  #  end

  ################################################################################

  # error
  aErr = reshifter(postAr - freqAr) |> p -> Flux.flatten(p)

  # setup
  mPen, hmm = setup(aErr)
  # process
  for i in 1:5
    errDc[k] = process(hmm, aErr, mPen)
  end


  #  # compressed
  #  compAr = cpu(model[1]).(freqAr)
  #  aComp = reshifter(compAr, length(compAr[1])) |> p -> Flux.flatten(p)
  #
  #  # setup
  #  mPen, hmm = setup(aComp)
  #  # process
  #  for i in 1:5
  #    compDc[k] = process(hmm, aComp, mPen)
  #  end
  #

  ################################################################################

end

################################################################################

runHeatmap(errDc)

################################################################################

end

################################################################################

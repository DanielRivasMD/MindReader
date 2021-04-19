################################################################################

import Parameters: @with_kw

# set hyperparameters
@with_kw mutable struct Params
  η::Float64 = 1e-3                               # learning rate
  epochs::Int = 10                                # number of epochs
  batchsize::Int = 1000                           # batch size for training
  throttle::Int = 5                               # throttle timeout
  labels::Array{Int64, 1} = 0:7                   # training labels three-column annotation
  device::Function = gpu                          # set as gpu, if gpu available
end

################################################################################

using Flux

################################################################################

#  declare tool directories
begin
  utilDir    = "Utilities/"
  annotDir   = "Annotator/"
  signalDir  = "SignalProcessing/"
  arqDir     = "Architect/"
  hmmDir     = "HiddenMarkovModel/"
  pcaDir     = "PrincipalComponentAnalysis/"
  imgDir     = "ImageProcessing/"
  graphDir   = "Graphics/"
end;

################################################################################

#  load functions
begin
  @info("Loading modules...")
  include( string(utilDir,    "fileReaderEDF.jl") )
  include( string(utilDir,    "electrodeID.jl") )
  include( string(utilDir,    "stateStats.jl") )
  include( string(annotDir,   "fileReaderXLSX.jl") )
  include( string(annotDir,   "annotationCalibrator.jl") )
  include( string(signalDir,  "signalBin.jl") )
  include( string(signalDir,  "fastFourierTransform.jl") )
  include( string(hmmDir,     "hiddenMarkovModel.jl") )
  include( string(arqDir,     "architect.jl") )
  include( string(arqDir,     "shapeShifter.jl") )
  include( string(arqDir,     "autoencoder.jl") )
  include( string(arqDir,     "SMPerceptron.jl") )
  include( string(graphDir,   "statesHeatMap.jl") )
  include( string(utilDir,    "screening.jl") )
  include( string(utilDir,    "permutations.jl") )
end;

################################################################################

elecDc = Dict{String, Array{Array{Float64, 1}, 1}}()

listFiles = readdir("/Users/drivas/Factorem/EEG/data/patientEEG/")
listFiles = contains.(listFiles, "edf") |> p -> getindex(listFiles, p)
listFiles = listFiles[1:3]

winBin = 128
overlap = 4

annotAr = Array

labSw = true
for file in listFiles

  @info file
  file = string("/Users/drivas/Factorem/EEG/data/patientEEG/", file)
  #  read data
  begin
    # read edf file
    edfDf, startTime, recordFreq = getSignals(file)

    # read xlsx file
    xfile = replace(file, "edf" => "xlsx")
    xDf = xread(xfile)

    # labels array
    labelAr = annotationCalibrator(
      xDf,
      startTime = startTime,
      recordFreq = recordFreq,
      signalLength = size(edfDf, 1),
      binSize = winBin,
      binOverlap = overlap
    )

    # label encoding
    labelAr = labelParser(labelAr)

    # concatenate labels
    if labSw
      global annotAr = copy(labelAr)
      global labSw = false
    else
      annotAr = [annotAr; labelAr]
    end

    # calculate fft
    freqDc = extractChannelFFT(edfDf, binSize = winBin, binOverlap = overlap)

    # iterate on electrodes
    for (k, v) in freqDc
      freqAr = shifter(v)
      if ! haskey(elecDc, k)
        elecDc[k] = freqAr
      else
        append!(elecDc[k], freqAr)
      end
    end

  end;

end

################################################################################

for (k, v) in elecDc
  println()
  @info k
  println()
  model = buildPerceptron(size(v[1], 1), relu, Params)
  model = modelTrain(reshifter(v), annotAr, model, Params)
end

################################################################################


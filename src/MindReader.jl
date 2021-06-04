################################################################################

module MindReader

################################################################################

# dependencies
using DataFrames
using Dates
using EDF

using FreqTables
using DelimitedFiles
# using CairoMakie

using XLSX

using FFTW
using Flux

import Flux: mse, throttle, ADAM
using Flux.Data: DataLoader
using Flux: onehotbatch, onecold, logitcrossentropy, throttle, @epochs
using Parameters: @with_kw
# using CUDAapi

using NamedArrays
using OrderedCollections

using StatsBase

using CSV

################################################################################

# exports
export getsignals, getedfStart, getedfRecordFreq         # fileReaderEDF

export xread                                        # fileReaderXLSX

export annotationReader, annotationCalibrator, labelParser # annotationCalibrator

export extractChannelSignalBin, extractSignalBin # signalBin

export extractChannelFFT, extractFFT, binChannelFFT # fastFourierTransform

export buildAutoencoder, buildAssymmetricalAutoencoder, buildRecurrentAutoencoder, buildDeepRecurrentAutoencoder, buildPerceptron # architect

export shifter, reshifter # shapeShifter

export modelTrain, modelTest, modelSS, accuracy, lossAll, loadData # autoencoder, SMPerceptron

export runHeatmap, plotChannelsHeatmap, writePerformance # statesHeatMap

export collectState, stateStats, summarizeStats, groundStateRatio, plotStatesHeatmap # stateStats

export ss, convertFqDf, convertFqDfTempl, sensspec # screening

# export rdPerm # permutations

export writeHMM, shiftHMM, writePerformance

################################################################################

# declare tool directories
begin
  utilDir    = "Utilities/"
  montageDir = "Montage/"
  annotDir   = "Annotator/"
  signalDir  = "SignalProcessing/"
  arqDir     = "Architect/"
  # hmmDir     = "HiddenMarkovModel/"
  pcaDir     = "PrincipalComponentAnalysis/"
  imgDir     = "ImageProcessing/"
  graphDir   = "Graphics/"
  performDir = "Performance/"
end;

################################################################################

# load functions
begin
  include( string(utilDir,    "fileReaderEDF.jl") )
  include( string(montageDir, "electrodeID.jl") )
  include( string(annotDir,   "fileReaderXLSX.jl") )
  include( string(annotDir,   "annotationCalibrator.jl") )
  include( string(signalDir,  "signalBin.jl") )
  include( string(signalDir,  "fastFourierTransform.jl") )
  # include( string(hmmDir,     "hiddenMarkovModel.jl") )
  include( string(arqDir,     "architect.jl") )
  include( string(arqDir,     "shapeShifter.jl") )
  include( string(arqDir,     "autoencoder.jl") )
  # include( string(arqDir,     "SMPerceptron.jl") )
  include( string(graphDir,   "statesHeatMap.jl") )
  include( string(performDir, "stateStats.jl") )
  include( string(performDir, "screening.jl") )
  # include( string(performDir, "permutations.jl") )
  include( string(utilDir,    "writeCSV.jl") )
end;

################################################################################

end

################################################################################

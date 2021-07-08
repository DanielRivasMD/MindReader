################################################################################

module MindReader

################################################################################

# dependencies
using DataFrames
using Dates
using EDF

using Parameters

using FreqTables
using DelimitedFiles
# using CairoMakie

using XLSX

using FFTW
using Flux

import Flux: mse, throttle, ADAM
import Flux.Data: DataLoader
import Flux: onehotbatch, onecold, logitcrossentropy, throttle, @epochs
# using Parameters: @with_kw
# using CUDAapi

using NamedArrays
using OrderedCollections

using StatsBase

using CSV

using CairoMakie

################################################################################

# readEDF
export getSignals

# fileReaderXLSX
export xread

# annotationCalibrator
export annotationReader, annotationCalibrator, labelParser

# signalBin
export extractSignalBin

# fastFourierTransform
export extractFFT

# architect
export buildAutoencoder, buildAssymmetricalAutoencoder, buildRecurrentAutoencoder, buildDeepRecurrentAutoencoder, buildPerceptron

# shapeShifter
export shifter, reshifter

# autoencoder
export modelTrain

# # SMPerceptron
# export modelTest, modelSS, accuracy, lossAll, loadData

# statesHeatMap
export runHeatmap, plotChannelsHeatmap, writePerformance

# stateStats
export collectState, stateStats, summarizeStats, groundStateRatio, plotStatesHeatmap

# screening
export sensitivitySpecificity, predictiveValue, convertFqDf, convertFqDfTempl

# # permutations
# export rdPerm

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
  include( string(utilDir,    "readEDF.jl") )
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

# TODO: fix perceptron functions

################################################################################

end

################################################################################

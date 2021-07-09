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
import CairoMakie: Figure, Axis, Colorbar, Relative
import CairoMakie: heatmap!, save

################################################################################

# readEDF
export getSignals

# signalBin
export extractSignalBin

# fastFourierTransform
export extractFFT

# architect
export buildAutoencoder

# shapeShifter
export shifter, reshifter

# autoencoder
export modelTrain!

# stateStats
export collectState, stateStats, summarizeStats, groundStateRatio, plotStatesHeatmap

# screening
export sensitivitySpecificity, predictiveValue

# writeCSV
export writeHMM, writePerformance
# graphics
export renderGraphics

################################################################################

# declare tool directories
begin
  utilDir    = "Utilities/"
  montageDir = "Montage/"
  signalDir  = "SignalProcessing/"
  arqDir     = "Architect/"
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
  include( string(signalDir,  "signalBin.jl") )
  include( string(signalDir,  "fastFourierTransform.jl") )
  include( string(arqDir,     "architect.jl") )
  include( string(arqDir,     "shapeShifter.jl") )
  include( string(arqDir,     "autoencoder.jl") )
  include( string(graphDir,   "statesHeatMap.jl") )
  include( string(performDir, "stateStats.jl") )
  include( string(performDir, "screening.jl") )
  include( string(utilDir,    "writeCSV.jl") )
end;

################################################################################

end

################################################################################

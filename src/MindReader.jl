################################################################################

module MindReader

################################################################################

# dependencies
using Parameters
using DataFrames
using Dates
using EDF
using FreqTables
using DelimitedFiles
using NamedArrays
using OrderedCollections
using StatsBase
using CSV
using FFTW

# Flux
import Flux: Chain, Dense
import Flux: mse, throttle, ADAM
import Flux: throttle, params, train!
import Flux: @epochs
import Flux.Data: DataLoader

# CairoMakie
import CairoMakie: Figure, Axis, Colorbar, Relative
import CairoMakie: heatmap!, save

################################################################################

# readEDF
export getSignals

# writeCSV
export writeHMM, writePerformance

# screening
export sensitivitySpecificity, predictiveValue

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

# graphics
export mindGraphics

################################################################################

# declare tool directories
begin
  montageDir = "Montage/"                                  # EEG montage
  utilDir    = "Utilities/"                                # IO utilities
  performDir = "Performance/"                              # performance
  signalDir  = "SignalProcessing/"                         # preprocessing
  arqDir     = "Architect/"                                # neural network
  graphDir   = "Graphics/"                                 # graphic rendering
end;

################################################################################

# load functions
begin

  # EEG montage
  include( string(montageDir, "electrodeID.jl") )

  # IO utilities
  include( string(utilDir,    "readEDF.jl") )
  include( string(utilDir,    "writeCSV.jl") )

  # performance
  include( string(performDir, "screening.jl") )

  # preprocessing
  include( string(signalDir,  "signalBin.jl") )
  include( string(signalDir,  "fastFourierTransform.jl") )

  # neural network
  include( string(arqDir,     "architect.jl") )
  include( string(arqDir,     "shapeShifter.jl") )
  include( string(arqDir,     "autoencoder.jl") )

  # graphic rendering
  include( string(graphDir,   "statesHeatMap.jl") )

end;

################################################################################

end

################################################################################

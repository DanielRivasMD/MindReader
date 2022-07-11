####################################################################################################

module MindReader

####################################################################################################

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
using HiddenMarkovModelReaders

# Flux
using Flux: Chain, Dense
using Flux: mse, throttle, ADAM
using Flux: throttle, params, train!
using Flux: @epochs
using Flux.Data: DataLoader

####################################################################################################

# readEDF
export getSignals

# writeCSV
export writePerformance

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

####################################################################################################

# declare tool directories
begin
  montageDir = "Montage/"                                  # EEG montage
  utilDir    = "Utilities/"                                # IO utilities
  performDir = "Performance/"                              # performance
  signalDir  = "SignalProcessing/"                         # preprocessing
  arqDir     = "Architect/"                                # neural network
end;

####################################################################################################

# load functions
begin

  # EEG montage
  include(string(montageDir, "electrodeID.jl"))

  # IO utilities
  include(string(utilDir,    "readEDF.jl"))
  include(string(utilDir,    "writeCSV.jl"))

  # performance
  include(string(performDir, "screening.jl"))

  # preprocessing
  include(string(signalDir,  "signalBin.jl"))
  include(string(signalDir,  "fastFourierTransform.jl"))

  # neural network
  include(string(arqDir,     "architect.jl"))
  include(string(arqDir,     "shapeShifter.jl"))
  include(string(arqDir,     "autoencoder.jl"))

end;

####################################################################################################

end

####################################################################################################

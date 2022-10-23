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
  include(string(performDir, "performance.jl"))

  include(string(performDir, "accuracy.jl"))
  include(string(performDir, "fdr.jl"))
  include(string(performDir, "fnr.jl"))
  include(string(performDir, "for.jl"))
  include(string(performDir, "fpr.jl"))
  include(string(performDir, "fScore.jl"))
  include(string(performDir, "mcc.jl"))
  include(string(performDir, "npv.jl"))
  include(string(performDir, "ppv.jl"))
  include(string(performDir, "sensitivity.jl"))
  include(string(performDir, "specificity.jl"))
  include(string(performDir, "utils.jl"))

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

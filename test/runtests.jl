################################################################################

using MindReader
using Test
using DelimitedFiles

################################################################################

tests = [

  # private functions

  # export functions
  "screening.jl",
  "writeCSV.jl",

]

################################################################################

@testset verbose = true "MindReader" begin

  for τ ∈ tests
    include(τ)
  end
end

################################################################################

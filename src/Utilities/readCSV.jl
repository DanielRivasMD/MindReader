####################################################################################################

"""

    reconstructHMM(hmmDc::Dict{S, HMM}, filename::S, channel::S) where S <: String

# Description
Reconstruct hidden markov model.


See also: [`writeHMM`](@ref)
"""
function reconstructHMM(path::S, filename::S, channels::Vector{S}) where S <: String
  hmmDc = Dict{S, HMM}()
  for κ ∈ channels
    hmmDc[κ] = reconstructHMM(path, string(filename, "_", κ))
  end
  return hmmDc
end

####################################################################################################

"reconstruct hidden Markov model with empty data"
function reconstructHMM(path::S, filename::S) where S <: String
  return HMM([zeros(0)], readHMMmodel(path, filename), readHMMtraceback(path, filename))
end

"load hidden Markov model model"
function readHMMmodel(path::S, filename::S) where S <: String
  return readdf(string(path, filename, "_", "model", ".csv"), ',') |> π -> map(χ -> π[:, χ], 1:size(π, 2))
end

"load hidden Markov model traceback"
function readHMMtraceback(path::S, filename::S) where S <: String
  return readdf(string(path, filename, "_traceback", ".csv"), ',') |> π -> π[:, 1]
end

####################################################################################################

"read dataframe"
function readdf(path, sep = '\t')
  ƒ, п = readdlm(path, sep, header = true)
  DataFrame(ƒ, п |> vec)
end

####################################################################################################

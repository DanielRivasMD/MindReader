####################################################################################################

"""

    reconstructHMM(hmmDc::Dict{S, HMM}, filename::S, channel::S) where S <: String

# Description
Reconstruct hidden markov model.


See also: [`writeHMM`](@ref)
"""
function reconstructHMM(hmmDc::Dict{S, HMM}, filename::S, channel::S) where S <: String
  for (κ, _) ∈ hmmDc
    hmmDc[κ] = reconstructHMM(string(filename, channel))
  end
  return hmmDc
end

####################################################################################################

"reconstruct hidden Markov model with empty data"
function reconstructHMM(filename::S) where S <: String
  return HMM([zeros(0)], readHMMmodel(filename), readHMMtraceback(filename))
end

"load hidden Markov model model"
function readHMMmodel(filename::S) where S <: String
  return readdf(string(filename, "_model.csv"), ',') |> π -> map(χ -> π[:, χ], 1:size(π, 2))
end

"load hidden Markov model traceback"
function readHMMtraceback(filename::S) where S <: String
  return readdf(string(filename, "_traceback.csv"), ',') |> π -> π[:, 1]
end

####################################################################################################

"read dataframe"
function readdf(path, sep = '\t')
  ƒ, п = readdlm(path, sep, header = true)
  DataFrame(ƒ, п |> vec)
end

####################################################################################################

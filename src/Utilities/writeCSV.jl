################################################################################

import CSV

################################################################################

"write hidden markov model states & traceback wrapper"
function writeHMM(filePrefix::String, modelHMM::Dict{String, Tuple{Vector{Int64}, Vector{Vector{Float64}}}})
  for (k, v) in modelHMM
    filename = string( filePrefix, string(k))
    writeHMM( string(filename, "_states", ".csv"), v[1], k)
    writeHMM( string(filename, "_traceb", ".csv"), v[2])
  end
end

################################################################################

"write hidden markov model states wrapper"
function writeHMM(filename::String, statesHMM::Vector{Int64}, channel::String)
  CSV.write(filename, shiftHMM(statesHMM, channel))
end

"write hidden markov model traceback wrapper"
function writeHMM(filename::String, tracebHMM::Vector{Vector{Float64}})
  CSV.write(filename, shiftHMM(tracebHMM))
end

################################################################################

"reorder hidden markov model states into table to write"
function shiftHMM(statesHMM::Vector{Int64}, channel::String)
  return Tables.table(reshape(statesHMM, (length(statesHMM), 1)), header = [channel])
end

"reorder hidden markov model traceback vectors into table to write"
function shiftHMM(tracebHMM::Vector{Vector{Float64}})
  outMt = Array{Float64, 2}(undef, length(tracebHMM[1]), length(tracebHMM))
  for ix in 1:length(tracebHMM)
    outMt[:, ix] = tracebHMM[ix]
  end
  return Tables.table(outMt, header = [Symbol("S$i") for i = 1:size(outMt, 2)])
end

################################################################################

function writePerformance(stDc::Dict{String, Array{Float64, 2}})
  outAr = Array{Any, 2}(undef, length(stDc) + 1, 3)
  ct = 1
  outAr[1, :] .= ["Electrode", "Sensitivity", "Specificity"]
  for (k, v) in stDc
    ct += 1
    outAr[ct, :] = [k v]
  end
  return outAr
end

################################################################################

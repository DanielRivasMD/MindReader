################################################################################

"""

    writeHMM(filePrefix::S, modelHMM::HMM) where S <: String

# Description
Write hidden markov model states & traceback wrapper


See also: [`writePerformance`](@ref)
"""
function writeHMM(filePrefix::S, modelHMM::HMM) where S <: String
  for (κ, υ) ∈ modelHMM
    filename = string( filePrefix, string(κ))
    writeHMM( string(filename, "_states", ".csv"), υ[1], κ)
    writeHMM( string(filename, "_traceb", ".csv"), υ[2])
  end
end

################################################################################

"""

    writeHMM(filename::S, statesHMM::Vector{T}, channel::S) where S <: String where T <: Number

# Description
Write hidden markov model states wrapper.


"""
function writeHMM(filename::S, statesHMM::Vector{T}, channel::S) where S <: String where T <: Number
  CSV.write(filename, shiftHMM(statesHMM, channel))
end

"""

    writeHMM(filename::S, tracebHMM::Vector{Vector{T}}) where S <: String where T <: Number

# Description
Write hidden markov model traceback wrapper


"""
function writeHMM(filename::S, tracebHMM::Vector{Vector{T}}) where S <: String where T <: Number
  CSV.write(filename, shiftHMM(tracebHMM))
end

################################################################################

"reorder hidden markov model states into table to write"
function shiftHMM(statesHMM::Vector{T}, channel::S) where S <: String where T <: Number
  return Tables.table(reshape(statesHMM, (length(statesHMM), 1)), header = [channel])
end

"reorder hidden markov model traceback vectors into table to write"
function shiftHMM(tracebHMM::Vector{Vector{T}}) where T <: Number
  outMt = Array{Float64, 2}(undef, length(tracebHMM[1]), length(tracebHMM))
  for ι ∈ 1:length(tracebHMM)
    outMt[:, ι] = tracebHMM[ι]
  end
  return Tables.table(outMt, header = [Symbol("S$i") for i = 1:size(outMt, 2)])
end

################################################################################

"""

    writePerformance(stDc::Dict{S, Array{T, 2}}) where S <: String where T <: Number

# Description
Write model performance to CSV file.


See also: [`writeHMM`](@ref)
"""

function writePerformance(stDc::Dict{S, Array{T, 2}}) where S <: String where T <: Number
  outAr = Array{Any, 2}(undef, length(stDc) + 1, 3)
  outAr[1, :] .= ["Electrode", "Sensitivity", "Specificity"]
  for (ζ, (κ, υ)) ∈ enumerate(stDc)
    outAr[ζ + 1, :] = [κ υ]
  end
  return outAr
end

################################################################################

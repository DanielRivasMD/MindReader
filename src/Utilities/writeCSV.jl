####################################################################################################

"""

    writeHMM(hmmDc::Dict{S, HMM}, shParams::Dict) where S <: String

# Description
Write hidden markov model states and traceback wrapper.


See also: [`writePerformance`](@ref)
"""
function writeHMM(hmmDc::Dict{S, HMM}, shParams::Dict) where S <: String
  if haskey(shParams, "outDir") && haskey(shParams, "input")
    return writeHMM(
      string(
        shParams["outDir"],
        "hmm/",
        replace(shParams["input"], ".edf" => "_")
      ),
      hmmDc,
    )
  else
    @error "Variables are not defined in dictionary"
  end
end

####################################################################################################

"""

    writeHMM(filePrefix::S, hmmDc::Dict{S, HMM}) where S <: String

# Description
Write hidden markov model traceback and model wrapper.


See also: [`writePerformance`](@ref)
"""
function writeHMM(filePrefix::S, hmmDc::Dict{S, HMM}) where S <: String
  for (κ, υ) ∈ hmmDc
    filename = string(filePrefix, string(κ))
    writeHMM(string(filename, "_traceback", ".csv"), υ.traceback, κ)
    writeHMM(string(filename, "_model", ".csv"), υ.model)
  end
end

####################################################################################################

"""

    writeHMM(filename::S, hmmTraceback::Array{T, 1}, channel::S) where S <: String where T <: Integer

# Description
Write hidden markov traceback states wrapper.


See also: [`writePerformance`](@ref)
"""
function writeHMM(filename::S, hmmTraceback::Array{T, 1}, channel::S) where S <: String where T <: Integer
  CSV.write(filename, shiftHMM(hmmTraceback, channel))
end

"""

    writeHMM(filename::S, hmmModel::Array{Array{T, 1}, 1}) where S <: String where T <: AbstractFloat

# Description
Write hidden markov model model wrapper.


See also: [`writePerformance`](@ref)
"""
function writeHMM(filename::S, hmmModel::Array{Array{T, 1}, 1}) where S <: String where T <: AbstractFloat
  CSV.write(filename, shiftHMM(hmmModel))
end

####################################################################################################

"""

    writePerformance(performanceDc::D{S, Array{T, 2}})
    where D <: Dict
    where S <: String
    where T <: Number

# Description
Transform model performance to table for writing.


See also: [`getSignals`](@ref)
"""
function writePerformance(performanceDc::D{S, Array{T, 2}}) where D <: Dict where S <: String where T <: Number
  outAr = Array{Any, 2}(undef, length(performanceDc) + 1, 3)
  outAr[1, :] .= ["Electrode", "Sensitivity", "Specificity"]
  for (ι, (κ, υ)) ∈ enumerate(performanceDc)
    outAr[ι + 1, :] = [κ υ]
  end
  return outAr
end

####################################################################################################

"""

    writePerformance(filename::S, performanceDc::D{S, Array{T, 2}}, delim::S = ",")
    where D <: Dict
    where S <: String
    where T <: Number

# Description
Write model performance to CSV file.


See also: [`getSignals`](@ref)
"""
function writePerformance(filename::S, performanceDc::D{S, Array{T, 2}}, delim::S = ",") where D <: Dict where S <: String where T <: Number
  writedlm(
    filename,
    writePerformance(performanceDc),
    delim,
  )
end

####################################################################################################

"reorder hidden markov model states into table to write"
function shiftHMM(hmmTraceback::Array{T, 1}, channel::S) where S <: String where T <: Integer
  return Tables.table(reshape(hmmTraceback, (length(hmmTraceback), 1)), header = [channel])
end

"reorder hidden markov model traceback vectors into table to write"
function shiftHMM(hmmModel::Array{Array{T, 1}, 1}) where T <: AbstractFloat
  outMt = Array{Float64, 2}(undef, length(hmmModel[1]), length(hmmModel))
  for (ι, υ) ∈ enumerate(hmmModel)
    outMt[:, ι] = υ
  end
  return Tables.table(outMt, header = [Symbol("S$ο") for ο = 1:size(outMt, 2)])
end

####################################################################################################

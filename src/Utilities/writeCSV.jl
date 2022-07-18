####################################################################################################

"""

    writePerformance(performanceDc::D)
      where D <: Dict{S, M}
      where S <: String
      where M <: Matrix{N}
      where N <: Number

# Description
Transform model performance to table for writing.


See also: [`getSignals`](@ref)
"""
function writePerformance(performanceDc::D) where D <: Dict{S, M} where S <: String where M <: Matrix{N} where N <: Number
  outAr = Matrix{Any}(undef, length(performanceDc) + 1, 3)
  outAr[1, :] .= ["Electrode", "Sensitivity", "Specificity"]
  for (ι, (κ, υ)) ∈ enumerate(performanceDc)
    outAr[ι + 1, :] = [κ υ]
  end
  return outAr
end

####################################################################################################

"""

    writePerformance(filename::S, performanceDc::D, delim::S = ",")
      where S <: String
      where D <: Dict{S, M}
      where M <: Matrix{N}
      where N <: Number

# Description
Write model performance to CSV file.


See also: [`getSignals`](@ref)
"""
function writePerformance(filename::S, performanceDc::D, delim::S = ",") where S <: String where D <: Dict{S, M} where M <: Matrix{N} where N <: Number
  writedlm(
    filename,
    writePerformance(performanceDc),
    delim,
  )
end

####################################################################################################

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

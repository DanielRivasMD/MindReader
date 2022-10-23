####################################################################################################

"""

    writePerformance(performanceTp, electrode::S)
      where S <: String

# Description
Transform model predictive performance to table for writing.


See also: [`getSignals`](@ref)
"""
function writePerformance(performanceTp, electrode::S) where S <: String
  Ω = Matrix{Any}(undef, 1, length(performanceTp) + 1)
  Ω[1, 1] = electrode
  for (ι, υ) ∈ enumerate(performanceTp)
    Ω[1, ι + 1] = υ
  end
  return Ω
end

####################################################################################################

"""

    writePerformance(performanceDc)

# Description
Transform model predictive performance to table for writing.


See also: [`getSignals`](@ref)
"""
function writePerformance(performanceDc)
  firstPerformance = performanceDc[performanceDc |> keys .|> string |> π -> getindex(π, 1)]
  Ω = Matrix{Any}(undef, length(performanceDc) + 1, length(firstPerformance) + 1)
  Ω[1, :] .= ["Electrode"; [ι for ι ∈ string.(keys(firstPerformance))]]
  for (ι, (κ, υ)) ∈ enumerate(performanceDc)
    Ω[ι + 1, :] = writePerformance(υ, κ)
  end
  return Ω
end

####################################################################################################

"""

    writePerformance(filename::S, performanceTp;
    delim::S = ",")
      where S <: String

# Description
Write model predictive performance to CSV file.


See also: [`getSignals`](@ref)
"""
function writePerformance(filename::S, performanceTp, electrode::S; delim::S = ",") where S <: String
  writedlm(
    filename,
    writePerformance(performanceTp, electrode),
    delim,
  )
end

####################################################################################################

"""

    writePerformance(filename::S, performanceDc;
    delim::S = ",")
      where S <: String

# Description
Write model predictive performance to CSV file.


See also: [`getSignals`](@ref)
"""
function writePerformance(filename::S, performanceDc; delim::S = ",") where S <: String
  writedlm(
    filename,
    writePerformance(performanceDc),
    delim,
  )
end

####################################################################################################

####################################################################################################

"""

    writePerformance(performanceDSF)
      where DSF <: Dict{S, AF}
      where S <: String
      where AF <: AbstractFloat

# Description
Transform model predictive performance to table for writing.


See also: [`getSignals`](@ref)
"""
function writePerformance(performanceDSF::DSF) where DSF <: Dict{S, AF} where S <: String where AF <: AbstractFloat
  Ω = Matrix{Any}(undef, 2, length(performanceDSF))
  for (ι, κ) ∈ enumerate(["Sensitivity", "Specificity", "Accuracy", "FScore", "PPV", "NPV", "FPR", "FNR", "FDR", "FOR", "MCC",])
    Ω[:, ι] .= [κ, performanceDSF[κ]]
  end
  return Ω
end

####################################################################################################

"""

    writePerformance(performanceDSF::DSF, electrode::S)
      where DSF <: Dict{S, AF}
      where AF <: AbstractFloat
      where S <: String

# Description
Transform model predictive performance to table for writing.


See also: [`getSignals`](@ref)
"""
function writePerformance(performanceDSF::DSF, electrode::S) where DSF <: Dict{S, AF} where AF <: AbstractFloat where S <: String
  Ω = Matrix{Any}(undef, 1, length(performanceDSF) + 1)
  Ω[1, 1] = electrode
  for (ι, κ) ∈ enumerate(["Sensitivity", "Specificity", "Accuracy", "FScore", "PPV", "NPV", "FPR", "FNR", "FDR", "FOR", "MCC",])
    Ω[1, ι + 1] = performanceDSF[κ]
  end
  return Ω
end

####################################################################################################

"""

    writePerformance(filename::S, performanceDSF::DSF;
    delim::S = ",")
      where DSF <: Dict{S, AF}
      where AF <: AbstractFloat
      where S <: String

# Description
Write model predictive performance to CSV file.


See also: [`getSignals`](@ref)
"""
function writePerformance(filename::S, performanceDSF::DSF; delim::S = ",") where DSF <: Dict{S, AF} where AF <: AbstractFloat where S <: String
  writedlm(
    filename,
    writePerformance(performanceDSF),
    delim,
  )
end

####################################################################################################

"""

    writePerformance(performanceDc::DDS)
      where DDS <: Dict{S, DSF}
      where DSF <: Dict{S, AF}
      where AF <: AbstractFloat
      where S <: String

# Description
Transform model predictive performance to table for writing.


See also: [`getSignals`](@ref)
"""
function writePerformance(performanceDDS::DDS) where DDS <: Dict{S, DSF} where DSF <: Dict{S, AF} where AF <: AbstractFloat where S <: String
  performanceVc = ["Sensitivity", "Specificity", "Accuracy", "FScore", "PPV", "NPV", "FPR", "FNR", "FDR", "FOR", "MCC",]
  Ω = Matrix{Any}(undef, length(performanceDDS) + 1, length(performanceVc) + 1)
  Ω[1, :] .= ["Electrode"; [ι for ι ∈ [performanceVc]]]
  for (ι, κ) ∈ enumerate(performanceVc)
    Ω[ι + 1, :] = writePerformance(performanceDDS[κ], κ)
  end
  return Ω
end

####################################################################################################

"""

    writePerformance(filename::S, performanceDDS::DDS;
    delim::S = ",")
      where DDS <: Dict{S, DSF}
      where DSF <: Dict{S, AF}
      where S <: String
      where AF <: AbstractFloat

# Description
Write model predictive performance to CSV file.


See also: [`getSignals`](@ref)
"""
function writePerformance(filename::S, performanceDDS::DDS; delim::S = ",") where DDS <: Dict{S, DSF} where DSF <: Dict{S, AF} where S <: String where AF <: AbstractFloat
  writedlm(
    filename,
    writePerformance(performanceDDS),
    delim,
  )
end

####################################################################################################

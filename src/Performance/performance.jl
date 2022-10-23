####################################################################################################

"""

    performance(ssDc::DSH, maskDc::DSV, labelVc)
      where DSH <: Dict{S, HMM}
      where DSV <: Dict{S, V}
      where S <: String
      where V <: Vector{I}
      where I <: Int

# Description
Iterate on Dictionary and calculate performance from a `Hidden Markov model` struct with mask.


See also: [`accuracy`](@ref),[`fScore`](@ref),[`sensitivity`](@ref),[`specificity`](@ref),[`PPV`](@ref),[`NPV`](@ref),[`FPR`](@ref),[`FNR`](@ref),[`FDR`](@ref),[`FOR`](@ref),[`MCC`](@ref)
"""
function performance(ssDc::DSH, maskDc::DSV, labelVc) where DSH <: Dict{S, HMM} where DSV <: Dict{S, V} where S <: String where V <: Vector{I} where I <: Int

  Ω = Dict{S, Array{Float64, 2}}()
  for (κ, υ) in ssDc
    outSensSpec = zeros(1, 2)
    (outSensSpec[1, 1], outSensSpec[1, 2]) = performance(υ.traceback[1:end .∉ [maskDc[κ]]], labelVc[1:end .∉ [maskDc[κ]]])
    Ω[κ] = outSensSpec
  end

  return Ω
end

####################################################################################################

"""

    performance(ssDc::DSH, labelVc)
      where DSH <: Dict{S, HMM}
      where S <: String

# Description
Iterate on Dictionary and calculate performance from a `Hidden Markov model` struct.


See also: [`accuracy`](@ref),[`fScore`](@ref),[`sensitivity`](@ref),[`specificity`](@ref),[`PPV`](@ref),[`NPV`](@ref),[`FPR`](@ref),[`FNR`](@ref),[`FDR`](@ref),[`FOR`](@ref),[`MCC`](@ref)
"""
function performance(ssDc::DSH, labelVc) where DSH <: Dict{S, HMM} where S <: String

  Ω = Dict{S, Array{Float64, 2}}()
  for (κ, υ) in ssDc
    outSensSpec = zeros(1, 2)
    (outSensSpec[1, 1], outSensSpec[1, 2]) = performance(υ.traceback, labelVc)
    Ω[κ] = outSensSpec
  end

  return Ω
end

####################################################################################################

"""

    performance(tbVc::V, labelMt::M)
      where V <: Vector{N}
      where M <: Matrix{N}
      where N <: Number

# Description
Calculate performance from prediction vector and supervised matrix.


See also: [`accuracy`](@ref),[`fScore`](@ref),[`sensitivity`](@ref),[`specificity`](@ref),[`PPV`](@ref),[`NPV`](@ref),[`FPR`](@ref),[`FNR`](@ref),[`FDR`](@ref),[`FOR`](@ref),[`MCC`](@ref)
"""
function performance(tbVc::V, labelMt::M) where V <: Vector{N} where M <: Matrix{N} where N <: Number

  # declare internal copy
  tbVec = copy(tbVc)

  # reassign frecuency labels
  labels = [1, 2]
  tbVec[findall(tbVec .> 1)] .= 2

  # add label columns
  labelVc = sum(labelMt, dims = 2)

  return performance(adjustFq(tbVec, labelVc, labels))
end

####################################################################################################

"""

    performance(tbVc::V, labelVc::V)
      where V <: Vector{N}
      where N <: Number

# Description
Calculate performance from prediction vector and supervised vector.


See also: [`accuracy`](@ref),[`fScore`](@ref),[`sensitivity`](@ref),[`specificity`](@ref),[`PPV`](@ref),[`NPV`](@ref),[`FPR`](@ref),[`FNR`](@ref),[`FDR`](@ref),[`FOR`](@ref),[`MCC`](@ref)
"""
function performance(tbVc::V, labelVc::V) where V <: Vector{N} where N <: Number

  # declare internal copy
  tbVec = copy(tbVc)

  # reassign frecuency labels
  labels = [1, 2]
  tbVec[tbVec .> 1] .= 2

  return performance(adjustFq(tbVec, labelVc, labels))
end

####################################################################################################

"""

    performance(ɒ::M)
      where M <: Matrix{N}
      where N <: Number

# Description
Calculate performance from contingency table or confusion matrix.

# Examples
```jldoctest
julia> χ = [10 40; 5 45]
julia> performance(χ)
(sensitivity = 0.6666666666666666, specificity = 0.5294117647058824)

julia> χ = [20 33; 10 37]
julia> performance(χ)
(sensitivity = 0.6666666666666666, specificity = 0.5285714285714286)

julia> χ = [20 180; 10 1820]
julia> performance(χ)
(sensitivity = 0.6666666666666666, specificity = 0.91)
```


See also: [`performance`](@ref),[`accuracy`](@ref),[`fScore`](@ref),[`sensitivity`](@ref),[`specificity`](@ref),[`PPV`](@ref),[`NPV`](@ref),[`FPR`](@ref),[`FNR`](@ref),[`FDR`](@ref),[`FOR`](@ref),[`MCC`](@ref)
"""
function performance(ɒ::M) where M <: Matrix{N} where N <: Number
  if size(ɒ) == (2, 2)
    return (
      sensitivity = sensitivity(ɒ),
      specificity = specificity(ɒ),
      accuracy = accuracy(ɒ),
      fScore = fScore(ɒ),
      PPV = PPV(ɒ),
      NPV = NPV(ɒ),
      FPR = FPR(ɒ),
      FNR = FNR(ɒ),
      FDR = FDR(ɒ),
      FOR = FOR(ɒ),
      MCC = MCC(ɒ),
    )
  else
    @error "Array does not have the proper size"
  end
end

####################################################################################################

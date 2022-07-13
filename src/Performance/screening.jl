####################################################################################################

# TODO: consider expanding wrappers into macros

"""

    sensitivitySpecificity(ssDc::Dict{S, HMM}, labelVc)
    where S <: String

# Description
Iterate on Dictionary and calculate sensitivity and specificity from a `Hidden Markov model` struct.


See also: [`predictiveValue`](@ref)
"""
function sensitivitySpecificity(ssDc::Dict{S, HMM}, labelVc) where S <: String

  Ω = Dict{S, Array{Float64, 2}}()
  for (κ, υ) in ssDc
    outSensSpec = zeros(1, 2)
    (outSensSpec[1, 1], outSensSpec[1, 2]) = sensitivitySpecificity(υ.traceback, labelVc)
    Ω[κ] = outSensSpec
  end

  return Ω
end

####################################################################################################

"""

    sensitivitySpecificity(tbVc::Vector{N}, labelMt::Matrix{N})
    where N <: Number

# Description
Calculate sensitivity and specificity from a `Hidden Markov model` struct.


See also: [`predictiveValue`](@ref)
"""
function sensitivitySpecificity(tbVc::Vector{N}, labelMt::Matrix{N}) where N <: Number

  # TODO: is there a way to not pass by reference?
  # declare internal copy
  tbVec = copy(tbVc)

  # reassign frecuency labels
  labels = [1, 2]
  tbVec[findall(tbVec .> 1)] .= 2

  # add label columns
  labelVc = sum(labelMt, dims = 2)

  return sensitivitySpecificity(adjustFq(tbVec, labelVc, labels))
end

####################################################################################################

"""

    sensitivitySpecificity(tbVc::Vector{N}, labelVc::Vector{N})
    where N <: Number

# Description
Calculate sensitivity and specificity from a `Hidden Markov model` struct.


See also: [`predictiveValue`](@ref)
"""
function sensitivitySpecificity(tbVc::Vector{N}, labelVc::Vector{N}) where N <: Number

  # declare internal copy
  tbVec = copy(tbVc)

  # reassign frecuency labels
  labels = [1, 2]
  tbVec[findall(tbVec .> 1)] .= 2

  return sensitivitySpecificity(adjustFq(tbVec, labelVc, labels))
end

####################################################################################################

"""

    sensitivitySpecificity(ɒ::Matrix{N})
    where N <: Number

# Description
Calculate sensitivity and specificity from 2 x 2 array.

# Examples
```jldoctest
julia> χ = [10 40; 5 45]
julia> sensitivitySpecificity(χ)
(sensitivity = 0.6666666666666666, specificity = 0.5294117647058824)

julia> χ = [20 33; 10 37]
julia> sensitivitySpecificity(χ)
(sensitivity = 0.6666666666666666, specificity = 0.5285714285714286)
```


See also: [`predictiveValue`](@ref)
"""
function sensitivitySpecificity(ɒ::Matrix{N}) where N <: Number
  if size(ɒ) == (2, 2)
    return (sensitivity = ɒ[1, 1] / (ɒ[1, 1] + ɒ[2, 1]), specificity = ɒ[2, 2] / (ɒ[2, 2] + ɒ[1, 2]))
  else
    @error "Array does not have the proper size"
  end
end

####################################################################################################

"""

    predictiveValue(pvDc::Dict{S, HMM}, labelVc)
    where S <: String

# Description
Iterate on Dictionary and calculate predictive values from a `Hidden Markov model` struct.


See also: [`sensitivitySpecificity`](@ref)
"""
function predictiveValue(pvDc::Dict{S, HMM}, labelVc) where S <: String

  # preallocate out dictionary
  Ω = Dict{S, Array{Float64, 2}}()

  # iterate on dictionary
  for (κ, υ) in pvDc
    outPredVal = zeros(1, 2)
    (outPredVal[1, 1], outPredVal[1, 2]) = predictiveValue(υ.traceback, labelVc)
    Ω[κ] = outPredVal
  end

  return Ω
end

####################################################################################################

"""

    predictiveValue(tbVc::Vector{N}, labelMt::Matrix{N})
    where N <: Number

# Description
Calculate predictive values from a `Hidden Markov model` struct.


See also: [`sensitivitySpecificity`](@ref)
"""
function predictiveValue(tbVc::Vector{N}, labelMt::Matrix{N}) where N <: Number

  # declare internal copy
  tbVec = copy(tbVc)

  # reassign frecuency labels
  labels = [1, 2]
  tbVec[findall(tbVec .> 1)] .= 2

  # add label columns
  labelVc = sum(labelMt, dims = 2)

  return predictiveValue(adjustFq(tbVec, labelVc, labels))
end

####################################################################################################

"""

    predictiveValue(tbVc::Vector{N}, labelVc::Vector{N})
    where N <: Number

# Description
Calculate predictive values from a `Hidden Markov model` struct.


See also: [`sensitivitySpecificity`](@ref)
"""
function predictiveValue(tbVc::Vector{N}, labelVc::Vector{N}) where N <: Number

  # declare internal copy
  tbVec = copy(tbVc)

  # reassign frecuency labels
  labels = [1, 2]
  tbVec[findall(tbVec .> 1)] .= 2

  return predictiveValue(adjustFq(tbVec, labelVc, labels))
end

####################################################################################################

"""

    predictiveValue(ɒ::Matrix{N})
    where N <: Number

# Description
Calculate positive and negative predictive values from 2 x 2 array.

# Examples
```jldoctest
julia> χ = [10 40; 5 45]
julia> predictiveValue(χ)
(positive = 0.2, negative = 0.9)

julia> χ = [20 33; 10 37]
julia> predictiveValue(χ)
(positive = 0.37735849056603776, negative = 0.7872340425531915)
```


See also: [`sensitivitySpecificity`](@ref)
"""
function predictiveValue(ɒ::Matrix{N}) where N <: Number
  if size(ɒ) == (2, 2)
    return (positive = ɒ[1, 1] / (ɒ[1, 1] + ɒ[1, 2]), negative = ɒ[2, 2] / (ɒ[2, 2] + ɒ[2, 1]))
  else
    @error "Array does not have the proper size"
  end
end

####################################################################################################

"transform freqtable => dataframe"
function convertFqDf(fq; colnames = ["Value", "Frecuency"])
  return DataFrames.DataFrame([names(fq)[1] fq.array], colnames)
end


"transform freqtable => dataframe template"
function convertFqDf(fq, templ; colnames = ["Value", "Frecuency"])

  fq = convertFqDf(fq)

  Ω = DataFrames.DataFrame([templ zeros(Int64, length(templ))], colnames)

  for ι ∈ 1:size(fq, 1)
    Ω[findall(fq[ι, 1] .== Ω[:, 1]), 2] .= fq[ι, 2]
  end

  return Ω
end

####################################################################################################

"adjust frecuency tables for concatenation"
function stFreqTb(fTb::NamedArray{I, 1})where I <: Int64
  sTb = size(fTb, 1)
  # de novo
  if sTb == 0
    fTb = [1, 2] |> freqtable |> reverse
    fTb .= 0

  # concatenate missing
  elseif sTb == 1
    added = copy(fTb)
    nPos = names(fTb)

    if sum.(nPos)[1] == 0
      NamedArrays.setnames!(added, [2], 1)
      added[1, :] .= 0
      fTb = [fTb; added]

    elseif sum.(nPos)[1] == 1
      NamedArrays.setnames!(added, [1], 1)
      added[1, :] .= 0
      fTb = [added; fTb]
    end

  # throw warning
  elseif sTb > 2
    @warn "frecuency table contains more than 2 values"
  end
  return fTb
end

####################################################################################################

"adjust & concatenate frecuency tables"
function adjustFq(tbVec, labelVc, labels)
  positives = tbVec[labelVc[:, 1] .== 1] |> freqtable |> π -> convertFqDf(π, labels) |> π -> sort(π, rev = true)
  negatives = tbVec[labelVc[:, 1] .== 0] |> freqtable |> π -> convertFqDf(π, labels) |> π -> sort(π, rev = true)
  return [positives[:, 2] negatives[:, 2]]
end

####################################################################################################

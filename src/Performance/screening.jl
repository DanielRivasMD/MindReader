################################################################################

"""

    sensitivitySpecificity(ssDc::Dict{S, HMM}, labelVc) where {S <: String}

# Description
Iterate on Dictionary and calculate sensitivity and specificity from a `Hidden Markov model` struct.


See also: [`predictiveValue`](@ref)
"""
function sensitivitySpecificity(ssDc::Dict{S, HMM}, labelVc) where {S <: String}

  outDc = Dict{S, Array{Float64, 2}}()
  for (κ, υ) in ssDc
    outSensSpec = zeros(1, 2)
    (outSensSpec[1, 1], outSensSpec[1, 2]) = sensitivitySpecificity(υ.traceback, labelVc)
    outDc[κ] = outSensSpec
  end

  return outDc
end

################################################################################

"""

    sensitivitySpecificity(tbVc::Array{T, 1}, labelMt::Array{T, 2}) where {T <: Number}

# Description
Calculate sensitivity and specificity from a `Hidden Markov model` struct.


See also: [`predictiveValue`](@ref)
"""
function sensitivitySpecificity(tbVc::Array{T, 1}, labelMt::Array{T, 2}) where {T <: Number}
  tbVec = copy(tbVc)

  # reassign frecuency labels
  labels = [1, 2]
  tbVec[findall(tbVec .> 1)] .= 2

  # add label columns
  labelVc = sum(labelMt, dims = 2)

  return sensitivitySpecificity(adjustFq(tbVec, labelVc, labels))
end

################################################################################

"""

    sensitivitySpecificity(tbVc::Array{T, 1}, labelVc::Array{T, 1}) where {T <: Number}

# Description
Calculate sensitivity and specificity from a `Hidden Markov model` struct.


See also: [`predictiveValue`](@ref)
"""
function sensitivitySpecificity(tbVc::Array{T, 1}, labelVc::Array{T, 1}) where {T <: Number}
  tbVec = copy(tbVc)

  # reassign frecuency labels
  labels = [1, 2]
  tbVec[findall(tbVec .> 1)] .= 2

  return sensitivitySpecificity(adjustFq(tbVec, labelVc, labels))
end

################################################################################

"""

    sensitivitySpecificity(ar::Array{T, 2}) where {T <: Number}

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
function sensitivitySpecificity(ar::Array{T, 2}) where {T <: Number}
  if size(ar) == (2, 2)
    return (sensitivity = ar[1, 1] / (ar[1, 1] + ar[2, 1]), specificity = ar[2, 2] / (ar[2, 2] + ar[1, 2]))
  else
    @error "Array does not have the proper size"
  end
end

################################################################################

"""

    predictiveValue(ar::Array{T, 2}) where {T <: Number}

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
function predictiveValue(ar::Array{T, 2}) where {T <: Number}
  if size(ar) == (2, 2)
    return (positive = ar[1, 1] / (ar[1, 1] + ar[1, 2]), negative = ar[2, 2] / (ar[2, 2] + ar[2, 1]))
  else
    @error "Array does not have the proper size"
  end
end

################################################################################

"transform freqtable => dataframe"
function convertFqDf(fq::NamedVector{T, Array{T, 1}, Tuple{OrderedDict{T, T}}}; colnames::Array{S, 1} = ["Value", "Frecuency"]) where {T <: Number} where {S <: String}
  return DataFrames.DataFrame([names(fq)[1] fq.array], colnames)
end


"transform freqtable => dataframe template"
function convertFqDf(fq::NamedVector{T, Array{T, 1}, Tuple{OrderedDict{T, T}}}, templ::Array{T, 1}; colnames::Array{S, 1} = ["Value", "Frecuency"]) where {T <: Number} where {S <: String}

  fq = convertFqDf(fq)

  outDf = DataFrames.DataFrame([templ zeros(Int64, length(templ))], colnames)

  for ix in 1:size(fq, 1)
    outDf[findall(fq[ix, 1] .== outDf[:, 1]), 2] .= fq[ix, 2]
  end

  return outDf
end

################################################################################

"adjust frecuency tables for concatenation"
function stFreqTb(fTb::NamedArray{Int64, 1})
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

################################################################################

"adjust & concatenate frecuency tables"
function adjustFq(tbVec, labelVc, labels)
  positives = tbVec[labelVc[:, 1].==1] |> freqtable |> π -> convertFqDf(π, labels) |> π -> sort(π, rev = true)
  negatives = tbVec[labelVc[:, 1].==0] |> freqtable |> π -> convertFqDf(π, labels) |> π -> sort(π, rev = true)
  return [positives[:, 2] negatives[:, 2]]
end

################################################################################

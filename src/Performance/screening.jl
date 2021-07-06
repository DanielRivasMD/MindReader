################################################################################

"""

    sensitivitySpecifiity(ar::Matrix{T}) where T <: Number

# Description
Calculate sensitivity and specificity from 2 x 2 array.

# Examples
```jldoctest
julia> χ = [10 40; 5 45]
julia> sensitivitySpecifiity(χ)
(sensitivity = 0.6666666666666666, specificity = 0.5294117647058824)

julia> χ = [20 33; 10 37]
julia> sensitivitySpecifiity(χ)
(sensitivity = 0.6666666666666666, specificity = 0.5285714285714286)
```

See also: [`predictiveValue`](@ref)

"""
function sensitivitySpecifiity(ar::Matrix{T}) where T <: Number
  if size(ar) == (2, 2)
    return (sensitivity = ar[1, 1] / ( ar[1, 1] + ar[2, 1] ), specificity = ar[2, 2] / ( ar[2, 2] + ar[1, 2] ))
  else
    @error "Matrix does not have the proper size"
  end
end

################################################################################

"""

    predictiveValue(ar::Matrix{T}) where T <: Number

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

See also: [`sensitivitySpecifiity`](@ref)
"""
function predictiveValue(ar::Matrix{T}) where T <: Number
  if size(ar) == (2, 2)
    return (positive = ar[1, 1] / ( ar[1, 1] + ar[1, 2] ), negative = ar[2, 2] / ( ar[2, 2] + ar[2, 1] ))
  else
    @error "Matrix does not have the proper size"
  end
end

################################################################################

# """
#
#     sensspec(data_loader, model)
#
# Calculate sensitivity and specificity from a DataLoader object
#
# """
# function sensspec(data_loader, model)
#   d, l = data_loader
#   d = data_loader.data[1] |> model |> onecold
#   l = data_loader.data[2] |> onecold
#
#   outNamedArray = [( d[l .== 2] |> freqtable |> p -> sort(p, rev = true)) ( d[l .== 1] |> freqtable |> reverse )]
#   if size(outNamedArray, 1) == 1
#     added = copy(outNamedArray)
#     NamedArrays.setnames!(added, [2], 1)
#     added[1, :] .= 0
#     outNamedArray = [outNamedArray; added]

################################################################################

"transform freqtable => dataframe"
function convertFqDf(fq::NamedVector{T, Vector{T}, Tuple{OrderedDict{T, T}}}; colnames::Vector{String} = ["Value", "Frecuency"]) where T <: Number
  return DataFrames.DataFrame([names(fq)[1] fq.array], colnames)
end

"transform freqtable => dataframe template"
function convertFqDfTempl(fq::NamedVector{T, Vector{T}, Tuple{OrderedDict{T, T}}}; colnames::Vector{String} = ["Value", "Frecuency"], templ::Vector{T}) where T <: Number

  fq = convertFqDf(fq)

  outDf = DataFrames.DataFrame([templ zeros(Int64, length(templ))], colnames)

  for ix in 1:size(fq, 1)
    outDf[findall(fq[ix, 1] .== outDf[:, 1]), 2] .= fq[ix, 2]
  end

  return outDf
end

################################################################################

"""

    sensitivitySpecifiity(tbVc::Array{T, 1}, labelVec::Vector{T}) where T <: Number

# Description
Calculate sensitivity and specificity from a `Hidden Markov model` struct

"""
function sensitivitySpecifiity(tbVc::Array{T, 1}, labelVec::Vector{T}) where T <: Number
  tbVec = copy(tbVc)

  # reassign frecuency labels
  labels = [1, 2]
  tbVec[findall(tbVec .> 1)] .= 2

  # adjust & concatenate frecuency tables
  positives = tbVec[labelVec[:, 1] .== 1] |> freqtable |> p -> convertFqDfTempl(p, templ = labels) |> p -> sort(p, rev = true)
  negatives = tbVec[labelVec[:, 1] .== 0] |> freqtable |> p -> convertFqDfTempl(p, templ = labels) |> p -> sort(p, rev = true)
  outNamedArray = [positives[:, 2] negatives[:, 2]]
  return sensitivitySpecifiity(outNamedArray)
end

################################################################################

"""

    sensitivitySpecifiity(ssDc::Dict{String, Tuple{Array{T, 1}, Array{Array{Float64, 1}, 1}}}, labelVec::Vector{T}) where T <: Number

# Description
Iterate on Dictionary and calculate sensitivity and specificity from a `Hidden Markov model` struct

"""
function sensitivitySpecifiity(ssDc::Dict{String, Tuple{Array{T, 1}, Array{Array{Float64, 1}, 1}}}, labelVec::Vector{T}) where T <: Number

  outDc = Dict{String, Array{Float64, 2}}()
  for (k, v) in ssDc
    outSensSpec = zeros(1, 2)
    (outSensSpec[1, 1], outSensSpec[1, 2]) = sensitivitySpecifiity(ssDc[k][1], labelVec)
    outDc[k] = outSensSpec
  end

  return outDc
end

################################################################################

"""

    stFreqTb(fTb::NamedArray{Int64, 1})

# Description
Adjust frecuency tables for concatenation

"""
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
  # through warning
  elseif sTb > 2
    @warn "frecuency table contains more than 2 values"
  end
  return fTb
end

################################################################################

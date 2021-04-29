################################################################################

using FreqTables
using NamedArrays
using OrderedCollections

################################################################################

"""

    ss(ar)

Calculate sensitivity and specificity from 2 x 2 array

"""
function ss(ar::Matrix{Int64})
  if size(ar) == (2, 2)
    return (sensitivity = ar[1, 1] / ( ar[1, 1] + ar[2, 1] ), specificity = ar[2, 2] / ( ar[2, 2] + ar[1, 2] ))
  else
    @error "Matrix does not have the proper size"
  end
end

################################################################################

"""

    sensspec(data_loader, model)

Calculate sensitivity and specificity from a DataLoader object

"""
function sensspec(data_loader, model)
  d, l = data_loader
  d = data_loader.data[1] |> model |> onecold
  l = data_loader.data[2] |> onecold

  outNamedArray = [( d[l .== 2] |> freqtable |> p -> sort(p, rev = true)) ( d[l .== 1] |> freqtable |> reverse )]
  if size(outNamedArray, 1) == 1
    added = copy(outNamedArray)
    NamedArrays.setnames!(added, [2], 1)
    added[1, :] .= 0
    outNamedArray = [outNamedArray; added]
  end
  return ss(outNamedArray)

end

################################################################################

"""

    sensspec(tbVec, labelVec)

Calculate sensitivity and specificity from a HMM

"""
function sensspec(tbVc::Array{Int64, 1}, labelVec::Array{Int64, 2})
  # reassign frecuency labels
  tbVec = copy(tbVc)
  tbVec[findall(tbVec .> 1)] .= 2
  tbVec[findall(tbVec .== 1)] .= 1
  # adjust & concatenate frecuency tables
  positives = tbVec[labelVec[:, 1] .== 1] |> freqtable |> p -> sort(p, rev = true) |> stFreqTb
  negatives = tbVec[labelVec[:, 1] .== 0] |> freqtable |> p -> sort(p, rev = true) |> stFreqTb
  outNamedArray = [positives negatives]
  return ss(outNamedArray)
end

################################################################################

function sensspec(ssDc::Dict{String, Tuple{Array{Int64, 1}, Array{Array{Float64, 1}, 1}}}, labelVec::Array{Int64, 2})

  outDc = Dict{String, Array{Float64, 2}}()
  for (k, v) in ssDc
    tmp = zeros(1, 2)
    (tmp[1, 1], tmp[1, 2]) = sensspec(ssDc[k][1], labelVec)
    outDc[k] = tmp
  end

  return outDc
end

################################################################################

"""

    stFreqTb(fTb::NamedArray{Int64, 1})

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

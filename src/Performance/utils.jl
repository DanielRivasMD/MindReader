####################################################################################################

"transform freqtable => dataframe"
function convertFqDf(fq; colnames = ["Value", "Frecuency"])
  return DataFrames.DataFrame([names(fq)[1] fq.array], colnames)
end


"transform freqtable => dataframe template"
function convertFqDf(fq, templ; colnames = ["Value", "Frecuency"])

  fq = convertFqDf(fq)

  Ω = DataFrames.DataFrame([templ zeros(Int64, length(templ))], colnames)

  for ι ∈ axes(fq, 1)
    Ω[findall(fq[ι, 1] .== Ω[:, 1]), 2] .= fq[ι, 2]
  end

  return Ω
end

####################################################################################################

"adjust frecuency tables for concatenation"
function stFreqTb(fTb::NaI) where NaI <: NamedArray{I, 1} where I <: Int64
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

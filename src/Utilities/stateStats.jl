################################################################################

import FreqTables

################################################################################

function collectState(inDc::Dict{String,Tuple{Array{Int64,1},Array{Array{Float64,1},1}}})

  keyString = inDc[convert.(String, keys(inDc))[1]][1]
  toHeat = zeros(length(inDc), length(keyString))
  # toHeat = zeros(length(inDc) + 3, length(inDc[convert.(String, keys(inDc))[1]][1]))
  c = size(toHeat, 1)
  for k in elecID
    if haskey(inDc, k)
      toHeat[c, :] = inDc[k][1]
      c -= 1
    else
      @info k
    end
  end
  return toHeat, keyString
end

################################################################################

function stateStats(stateAr::Array{Float64, 2}, numState = 5)
  statsAr = zeros(Int64, numState, size(stateAr, 1))                            # empty out array
  ct = 0
  for rw in eachrow(stateAr)                                                    # iterate on each row (channel)
    rwFq = FreqTables.freqtable(rw)                                             # get the frequency
    tmpFq = FreqTables.freqtable([1.:numState...])                              # adjust frecuency table for non-present values
    for jx in 1:numState
      ixs = findall(isequal.(names(tmpFq)[1][jx], names(rwFq)[1]))
      if sum(ixs) > 0
        tmpFq[jx] = rwFq[ixs[1]]
      else
        tmpFq[jx] = 0
      end
    end
    ct += 1
    statsAr[:, ct] = tmpFq.array                                                # collect frecuency into array
  end
  return statsAr
end

################################################################################

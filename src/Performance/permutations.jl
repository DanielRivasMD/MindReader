################################################################################

function rdPerm(errDc::Dict{String, Tuple{Array{Int64, 1}, Array{Array{Float64, 1}, 1}}}, labelAr::Array{Int64, 2}; nIter::Int64 = 1000, weighted::Bool)

  permDc = Dict{String, Array{Float64, 2}}()
  for (k, v) in errDc
    colPerm = zeros(Float64, nIter, 2)
    for i in 1:nIter
      if weighted
        # weigthed permutation
        fqTb = v[1] |> freqtable
        wrdVc = sample(1:5, Weights(map(x -> x / (fqTb.array |> sum), fqTb.array)), v[1] |> length)
        (colPerm[i, 1], colPerm[i, 2]) = sensspec(wrdVc, labelAr)
      else
        # random permutation
        rdVc = rand(1:5, v[1] |> length)
        (colPerm[i, 1], colPerm[i, 2]) = sensspec(rdVc, labelAr)
      end
    end
    permDc[k] = sum(colPerm, dims = 1) ./ nIter
  end

  return permDc
end

################################################################################

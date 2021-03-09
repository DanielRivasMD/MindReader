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

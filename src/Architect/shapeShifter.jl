################################################################################

"""

    shifter(inputAr)

# Description
Reshape signals for autoencoder.


See also: [`reshifter`](@ref)
"""
function shifter(inputAr)
  outAr = [
    Array{Float64}(
      undef,
      prod(size(inputAr)[1:2])
    )
    for _ ∈ 1:size(inputAr, 3)
  ]
  for ι ∈ 1:size(inputAr, 3)
    outAr[ι] = vec(inputAr[:, :, ι])
  end
  return outAr
end

################################################################################

"""

    reshifter(inputAr;
    outSize = length(inputAr[1]))

# Description
Reshape signals from autoencoder.


See also: [`shifter`](@ref)
"""
function reshifter(inputAr; outSize = length(inputAr[1]))
  ψ = length(inputAr[1]) / outSize |> π -> convert(Int64, π)
  outAr  = Array{Float64}(
    undef,
    ψ,
    outSize,
    length(inputAr)
  )

  for ι ∈ 1:length(inputAr)
    outAr[:, :, ι] = inputAr[ι] |> π -> reshape(π, ψ, outSize)
  end

  return outAr
end

################################################################################

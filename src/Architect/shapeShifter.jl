####################################################################################################

"""

    shifter(ɒ)

# Description
Reshape signals for autoencoder.


See also: [`reshifter`](@ref)
"""
function shifter(ɒ)
  Ω = [
    Array{Float64}(
      undef,
      prod(size(ɒ)[1:2])
    )
    for _ ∈ 1:size(ɒ, 3)
  ]
  for ι ∈ 1:size(ɒ, 3)
    Ω[ι] = vec(ɒ[:, :, ι])
  end
  return Ω
end

####################################################################################################

"""

    reshifter(ɒ;
    outSize = length(ɒ[1]))

# Description
Reshape signals from autoencoder.


See also: [`shifter`](@ref)
"""
function reshifter(ɒ; outSize = length(ɒ[1]))
  ʒ = length(ɒ[1]) / outSize |> π -> convert(Int64, π)
  Ω  = Array{Float64}(
    undef,
    ʒ,
    outSize,
    length(ɒ)
  )

  for ι ∈ 1:length(ɒ)
    Ω[:, :, ι] = ɒ[ι] |> π -> reshape(π, ʒ, outSize)
  end

  return Ω
end

####################################################################################################

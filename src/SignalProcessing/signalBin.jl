####################################################################################################

"""

    extractSignalBin(edfDf::DataFrame, params::D)
    where D <: Dict

# Description
Use `extractSignalBin` on EDF file per channel from shell arguments. Returns a dictionary with channel names as keys.


See also: [`extractFFT`](@ref)
"""
function extractSignalBin(edfDf::DataFrame, params::D) where D <: Dict
  if haskey(params, "window-size") && haskey(params, "bin-overlap")
    return extractSignalBin(edfDf, binSize = params["window-size"], binOverlap = params["bin-overlap"])
  else
    @error "Variables are not defined in dictionary"
  end
end

####################################################################################################


"""

    extractSignalBin(channel::A;
    binSize::N, binOverlap::N)
    where A <: Array
    where N <: Number

# Description
Bin channel signal.


See also: [`extractFFT`](@ref)
"""
function extractSignalBin(channel::A; binSize::N, binOverlap::N) where A <: Array where N <: Number
  # define variables
  stepSize = floor(Int64, binSize / binOverlap)
  signalSteps = 1:stepSize:length(channel)
  signalAr = Array{Float64}(
    undef,
    length(signalSteps),
    binSize
  )

  # iterate over signal bins
  for stepIx ∈ 1:length(signalSteps)
    signalBoundry = signalSteps[stepIx] + binSize - 1

    # extract signals
    if signalBoundry <= length(channel)
      signalAr[stepIx, :] = channel[signalSteps[stepIx]:signalBoundry]

    # adjust last bin
    elseif signalBoundry > length(channel)
      signalAr[stepIx, :] = [
        channel[signalSteps[stepIx]:end];
        (signalBoundry - length(channel) |> abs |> zeros)
      ]
    end

  end
  return signalAr
end

####################################################################################################

"""

    extractSignalBin(edfDf::DataFrame;
    binSize::N, binOverlap::N)
    where N <: Number

# Description
Use `extractSignalBin` on EDF file per channel. Returns a dictionary with channel names as keys.


See also: [`extractFFT`](@ref)
"""
function extractSignalBin(edfDf::DataFrame; binSize::N, binOverlap::N) where N <: Number
  @info("Binning channels signals...")
  channelDc = Dict()
  signalAr = begin
    stepSize = floor(Int64, binSize / binOverlap)
    signalSteps = 1:stepSize:size(edfDf, 1)
    Array{Float64}(
      undef,
      1,
      binSize,
      length(signalSteps)
    )
  end

  # iterate on dataframe channels
  for (ψ, ε) ∈ enumerate(names(edfDf))
    tmpAr = extractSignalBin(edfDf[:, ψ], binSize = binSize, binOverlap = binOverlap)
    for β ∈ 1:size(tmpAr, 1)
      signalAr[:, :, β] = tmpAr[β, :]
    end
    channelDc[ε] = copy(signalAr)
  end
  return channelDc
end

####################################################################################################

################################################################################

"""

    extractChannelSignalBin(channel;
    binSize, binOverlap)
    extractSignalBin(edfDf::DataFrames.DataFrame, params::Dict)

Bins channel signal
# Description
Use `extractSignalBin` on EDF file per channel from shell arguments. Returns a dictionary with channel names as keys.


See also: [`extractFFT`](@ref)
"""
function extractChannelSignalBin(channel::Array; binSize::Int64, binOverlap::Int64)
function extractSignalBin(edfDf::DataFrames.DataFrame, params::Dict)
  if haskey(params, "window-size") && haskey(params, "bin-overlap")
    return extractSignalBin(edfDf, binSize = params["window-size"], binOverlap = params["bin-overlap"])
  else
    @error "Variables are not defined in dictionary"
  end
end

################################################################################
  # define variables
  stepSize = floor(Int64, binSize / binOverlap)
  signalSteps = 1:stepSize:length(channel)
  signalAr = Array{Float64}(
    undef,
    length(signalSteps),
    binSize
  )

  # iterate over signal bins
  for stepIx in 1:length(signalSteps)
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

################################################################################

"""

    extractChannelSignalBin(edfDf, electrodeID;
    binSize, binOverlap)

Use extractChannelSignalBin on EDF file per channel

"""
function extractChannelSignalBin(edfDf::DataFrames.DataFrame; binSize::Int64, binOverlap::Int64)
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
  for (chl, elec) in enumerate(names(edfDf))
    tmpAr = extractChannelSignalBin(edfDf[:, chl], binSize = binSize, binOverlap = binOverlap)
    for bn in 1:size(tmpAr, 1)
      signalAr[:, :, bn] = tmpAr[bn, :]
    end
    channelDc[elec] = copy(signalAr)
  end
  return channelDc
end

################################################################################

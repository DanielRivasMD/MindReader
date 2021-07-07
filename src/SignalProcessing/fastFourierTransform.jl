################################################################################

"""

    extractFFT(edfDf::DataFrames.DataFrame, params::Dict)

# Description
Use `extractFFT` on EDF file per channel from shell arguments. Returns a dictionary with channel names as keys.


See also: [`extractSignalBin`](@ref)
"""
function extractFFT(edfDf::DataFrames.DataFrame, params::Dict)
  if haskey(params, "window-size") && haskey(params, "bin-overlap")
    return extractFFT(edfDf, binSize = params["window-size"], binOverlap = params["bin-overlap"])
  else
    @error "Variables are not defined in dictionary"
  end
end

################################################################################

"""

    extractFFT(channel::Array;
    binSize::T, binOverlap::T) where T <: Number

# Description
Apply fast fourier transform (FFT) to channel.


See also: [`extractSignalBin`](@ref)
"""
function extractFFT(channel::Array; binSize::T, binOverlap::T) where T <: Number
  # define variables
  stepSize = floor(Int32, binSize / binOverlap)
  signalSteps = 1:stepSize:length(channel)
  freqAr = Array{Float64}(
    undef,
    length(signalSteps),
    binSize
  )

  # iterate over signal bins
  for ι ∈ eachindex(signalSteps)
    signalBoundry = signalSteps[ι] + binSize - 1

    # extract channel
    if signalBoundry <= length(channel)
      channelExtract = [
        channel[signalSteps[ι]:signalBoundry];
        zeros(binSize)
      ]

    # adjust last bin
    elseif signalBoundry > length(channel)
      channelExtract = [
        channel[signalSteps[ι]:end];
        (signalBoundry - length(channel) |> abs |> zeros);
        zeros(binSize)
      ]
    end

    # calculate fourier transform
    fftChannel = fft(channelExtract)
    realFft = abs.(fftChannel)
    freqAr[ι, :] = realFft[1:binSize]

  end
  return freqAr
end

################################################################################

"""

    edfDf::DataFrames.DataFrame;
    binSize::T, binOverlap::T) where T <: Number

# Description
Use `extractFFT` on EDF file per channel. Returns a dictionary with channel names as keys.


See also: [`extractSignalBin`](@ref)
"""
function extractFFT(edfDf::DataFrames.DataFrame; binSize::T, binOverlap::T) where T <: Number
  @info "Extracting channels frecuencies..."
  channelDc = Dict()
  freqAr = begin
    stepSize = floor(Int32, binSize / binOverlap)
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
    α = extractFFT(edfDf[:, ψ], binSize = binSize, binOverlap = binOverlap)
    for β ∈ 1:size(α, 1)
      freqAr[:, :, β] = α[β, :]
    end
    channelDc[ε] = copy(freqAr)
  end
  return channelDc
end

################################################################################

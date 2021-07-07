################################################################################

"""

    extractChannelFFT(channel;
    binSize, binOverlap)

Apply fast fourier transform (FFT) to channel

"""
function extractChannelFFT(channel; binSize, binOverlap)
  # define variables
  stepSize = floor(Int32, binSize / binOverlap)
  signalSteps = 1:stepSize:length(channel)
  freqAr = Array{Float64}(
    undef,
    length(signalSteps),
    binSize
  )

  # iterate over signal bins
  for stepIx in eachindex(signalSteps)
    signalBoundry = signalSteps[stepIx] + binSize - 1

    # extract channel
    if signalBoundry <= length(channel)
      channelExtract = [
        channel[signalSteps[stepIx]:signalBoundry];
        zeros(binSize)
      ]

    # adjust last bin
    elseif signalBoundry > length(channel)
      channelExtract = [
        channel[signalSteps[stepIx]:end];
        (signalBoundry - length(channel) |> abs |> zeros);
        zeros(binSize)
      ]
    end

    # calculate fourier transform
    fftChannel = FFTW.fft(channelExtract)
    realFft = abs.(fftChannel)
    freqAr[stepIx, :] = realFft[1:binSize]

  end
  return freqAr
end

# TODO: why separate fft by bins if they represent one single temparary frame

################################################################################

"""

    extractChannelFFT(edfDf, electrodeID;
    binSize, binOverlap)

Use extractChannelFFT on EDF file per channel

"""
function extractChannelFFT(edfDf::DataFrames.DataFrame; binSize::Int64, binOverlap::Int64)
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
  for (chl, elec) in enumerate(names(edfDf))
    tmpAr = extractChannelFFT(edfDf[:, chl], binSize = binSize, binOverlap = binOverlap)
    for bn in 1:size(tmpAr, 1)
      freqAr[:, :, bn] = tmpAr[bn, :]
    end
    channelDc[elec] = copy(freqAr)
  end
  return channelDc
end

################################################################################

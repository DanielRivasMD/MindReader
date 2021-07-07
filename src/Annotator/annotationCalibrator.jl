################################################################################

"obtain seizure time [physionet]"
function getSeizureSec(annot::S) where S <: String
  annot |> π -> findfirst(':', π) |> π -> getindex(annot, π + 2:length(annot)) |> π -> replace(π, " seconds" => "") |> Second
end

"obtain number seizure events [physionet]"
function getSeizureNo(annot::S) where S <: String
  annot |> π -> replace(π, "Number of Seizures in File: " => "") |> π -> parse(Int64, π)
end

"obtain file name [physionet]"
function getSeizureFile(annot::S) where S <: String
  annot |> π -> replace(π, "File Name: " => "") |> π -> replace(π, ".edf" => "")
end

################################################################################

"""

    annotationReader(summaryFile::S) where S <: String

# Description
Extract anomaly events from summary file [physionet]. Return a dictionary with files as keys.


See also: [`annotationCalibrator`](@ref), [`labelParser`](@ref)
"""
function annotationReader(summaryFile::S) where S <: String
  @info "Reading annotations..."
  annotDc = Dict{String, Vector{Tuple{Second, Second}}}()
  lastFile = ""
  startTime = Second(0)
  endTime = Second(0)
  timeVc = [(startTime, endTime)]
  ν = 0
  ω = false
  ζ = false

  open(summaryFile) do Φ
    line = 0

    while !eof(Φ)

      line += 1
      φ = readline(Φ)
      if contains(φ, "File Name")
        lastFile = getSeizureFile(φ)
        ω = true
      elseif contains(φ, "Number of Seizures")
        ν = getSeizureNo(φ)
      elseif contains(φ, "Seizure") && contains(φ, "Start Time")
        startTime = getSeizureSec(φ)
      elseif contains(φ, "Seizure") && contains(φ, "End Time")
        endTime = getSeizureSec(φ)
        push!(timeVc, (startTime, endTime))
        if length(timeVc) == ν + 1
          ζ = true
        end
      end

      if ω && ζ
        ζ = false
        annotDc[lastFile] = timeVc[2:end]
        timeVc = [(startTime, endTime)]
      end

    end
  end

  return annotDc
end

################################################################################

"""

    annotationCalibrator(annotations::Vector{Tuple{S, S}};
    startTime::Time, recordFreq::Array{T, 1}, signalLength::T, shParams::Dict) where T <: Number where S <: Second

# Description
Calibrate timestamp from summary file [physionet].

# Arguments
`annotations` annotations summary [physionet].

`startTime` signal start time.

`recordFreq` recording frecuency.

`signalLength` recording length.

`shParams` dictionary with command line arguments to extract: `binSize` window bin size and `binOverlap` overlap.


See also: [`annotationReader`](@ref), [`labelParser`](@ref)
"""
function annotationCalibrator(annotations::Vector{Tuple{S, S}}; startTime::Time, recordFreq::Array{T, 1}, signalLength::T, shParams::Dict) where T <: Number where S <: Second
  @info "Calibrating annotations..."
  # collect recording frecuency
  recFreq = begin
    recAv = (sum(recordFreq)) / (length(recordFreq))
    recAv |> π -> convert(Int64, π)
  end

  # generate signal holder
  signalVec = zeros(signalLength)

  # collect annotations
  for α ∈ annotations
    emSt = α[1].value * recFreq
    emEn = (α[2].value * recFreq) + recFreq
    signalVec[emSt:emEn, :] .= 1
  end

  # binned signal
  binVec = begin
    binVec = extractSignalBin(signalVec, binSize = shParams["window-size"], binOverlap = shParams["bin-overlap"])
    binVec = sum(binVec, dims = 2)
    replace!(ρ -> ρ >= 1 ? 1 : 0, binVec)
    binVec = convert.(Int64, binVec)
    binVec[:, 1]
  end

  return binVec
end

################################################################################

"""

    annotationCalibrator(xDf;
    startTime::Time, recordFreq::Array{T, 1}, signalLength::T, shParams::Dict) where T <: Number

# Description
Calibrate annotations from XLSX.

# Arguments
`xDf` annotations from XLSX file.

`startTime` signal start time.

`recordFreq` recording frecuency.

`signalLength` recording length.

`shParams` dictionary with command line arguments to extract: `binSize` window bin size and `binOverlap` overlap.


See also: [`annotationReader`](@ref), [`labelParser`](@ref)
"""
function annotationCalibrator(xDf; startTime::Time, recordFreq::Array{T, 1}, signalLength::T, shParams::Dict) where T <: Number
  @info "Calibrating annotations..."
  # collect recording frecuency
  recFreq = begin
    recAv = (sum(recordFreq)) / (length(recordFreq))
    recAv |> π -> convert(Int64, π)
  end

  # fields to check
  fields = ["ST", "MA", "EM"]
  stepSize = floor(Int64, shParams["window-size"] / shParams["bin-overlap"])
  signalSteps = 1:stepSize:signalLength
  binArr = zeros(Int64, length(signalSteps), length(fields))

  for ο ∈ eachindex(fields)
    κ = fields[ο]

    # purge missing records on all columns
    toSupress = begin
      [ismissing(xDf[κ][j, i]) for j ∈ 1:size(xDf[κ], 1) for i ∈ 1:size(xDf[κ], 2)] |>
      π -> reshape(π, size(xDf[κ], 2), size(xDf[κ], 1)) |>
      π -> sum(π, dims = 1)
    end

    delete!(xDf[κ], (toSupress' .== size(xDf[κ], 2))[:, 1])

    # generate signal holder
    signalVec = zeros(signalLength)

    # collect annotations
    for ι ∈ 1:size(xDf[κ], 1)
      if !ismissing(xDf[κ][ι, :START]) & !ismissing(xDf[κ][ι, :END])
        emSt = xDf[κ][ι, :START] - startTime |> p -> convert(Dates.Second, p) |> p -> p.value * recFreq
        emEn = xDf[κ][ι, :END] - startTime |> p -> convert(Dates.Second, p) |> (p -> p.value * recFreq) |> p -> p + recFreq
        signalVec[emSt:emEn, :] .= 1
      else
        @warn "Annotation is not formatted properly & is not reliable"
      end
    end

    # binned signal
    binVec = begin
      binVec = extractSignalBin(signalVec, binSize = shParams["window-size"], binOverlap = shParams["bin-overlap"])
      binVec = sum(binVec, dims = 2)
      replace!(ρ -> ρ >= 1 ? 1 : 0, binVec)
      binVec = convert.(Int64, binVec)
      binVec[:, 1]
    end
    binArr[:, ο] = binVec
  end

  return binArr
end

################################################################################

"""

    labelParser(lbAr::Array{T, 2}) where T <: Number

# Description
Parse three-column array into binary encoding


See also: [`annotationReader`](@ref), See also: [`annotationCalibrator`](@ref)
"""
function labelParser(lbAr::Array{T, 2}) where T <: Number
  @info "Parsing annotations..."
  lbSz = size(lbAr, 1)
  tmpAr = Array{String}(undef, lbSz, 1)
  for ι ∈ 1:lbSz
    tmpAr[ι, 1] = string(lbAr[ι,  1], lbAr[ι, 2], lbAr[ι, 3], )
  end
  outAr = parse.(Int64, tmpAr, base = 2)
  outAr = reshape(outAr, (size(outAr, 1), ))
  return outAr
end

################################################################################

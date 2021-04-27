################################################################################

using DataFrames
using Dates

################################################################################

"obtain seizure time [physionet]"
function getSeizureSec(annot::String)
  annot |> p -> findfirst(':', p) |> p -> getindex(annot, p + 2:length(annot)) |> p -> replace(p, " seconds" => "") |> Second
end

"obtain number seizure events [physionet]"
function getSeizureNo(annot::String)
  annot |> p -> replace(p, "Number of Seizures in File: " => "") |> p -> parse(Int64, p)
end

"obtain file name [physionet]"
function getSeizureFile(annot::String)
  annot |> p -> replace(p, "File Name: " => "") |> p -> replace(p, ".edf" => "")
end

"""

    annotationReader(summaryFile)

Input

"""
function annotationReader(summaryFile::String)

  annotDc = Dict{String, Vector{Tuple{Second, Second}}}()
  lastFile = ""
  startTime = Second(0)
  endTime = Second(0)
  timeVc = [(startTime, endTime)]
  sno = 0
  fl = false
  sw = false

  open(summaryFile) do f
    line = 0

    while !eof(f)

      line += 1
      z = readline(f)
      if contains(z, "File Name")
        lastFile = getSeizureFile(z)
        fl = true
      elseif contains(z, "Number of Seizures")
        sno = getSeizureNo(z)
      elseif contains(z, "Seizure") & contains(z, "Start Time")
        startTime = getSeizureSec(z)
      elseif contains(z, "Seizure") & contains(z, "End Time")
        endTime = getSeizureSec(z)
        push!(timeVc, (startTime, endTime))
        if length(timeVc) == sno + 1
          sw = true
        end
      end

      if fl & sw
        sw = false
        annotDc[lastFile] = timeVc[2:end]
        timeVc = [(startTime, endTime)]
      end

    end
  end

  return annotDc
end

################################################################################

"""
    annotationCalibrator(annotations;
    startTime, recordFreq, signalLength, binSize, binOverlap)

Input annotations from summary file [physionet]

# Arguments
`annotations` annotations summary [physionet]

`startTime` signal start time

`recordFreq` recording frecuency

`signalLength` recording length

`binSize` window bin size

`binOverlap` overlap

"""
function annotationCalibrator(annotations::Vector{Tuple{Second, Second}}; startTime::Time, recordFreq::Array{Int16, 1}, signalLength::Int64, binSize::Int64, binOverlap::Int64)
  @info "Calibrating annotations..."
  # collect recording frecuency
  recFreq = begin
    recAv = (sum(recordFreq)) / (length(recordFreq))
    recAv |> p -> convert(Int64, p)
  end

  # generate signal holder
  signalVec = zeros(signalLength)

  # collect annotations
  for an in annotations
    emSt = an[1].value * recFreq
    emEn = (an[2].value * recFreq) + recFreq
    signalVec[emSt:emEn, :] .= 1
  end

  # binned signal
  binVec = begin
    binVec = extractChannelSignalBin(signalVec, binSize = binSize, binOverlap = binOverlap)
    binVec = sum(binVec, dims = 2)
    replace!(r -> r >= 1 ? 1 : 0, binVec)
    binVec = convert.(Int64, binVec)
    binVec[:, 1]
  end

  return binVec
end

################################################################################

"""

    annotationCalibrator(xDf;
    startTime, recordFreq, signalLength, binSize = 256, binOverlap = 8)

Input annotations from XLSX

# Arguments
`xDf` annotations from XLSX file

`startTime` signal start time

`recordFreq` recording frecuency

`signalLength` recording length

`binSize` window bin size

`binOverlap` overlap

"""
function annotationCalibrator(xDf; startTime::Time, recordFreq::Array{Int16, 1}, signalLength::Int64, binSize::Int64, binOverlap::Int64)

  @info "Calibrating annotations..."
  # collect recording frecuency
  recFreq = begin
    recAv = (sum(recordFreq)) / (length(recordFreq))
    recAv |> p -> convert(Int64, p)
  end


  # fields to check
  fields = ["ST", "MA", "EM"]
  stepSize = floor(Int64, binSize / binOverlap)
  signalSteps = 1:stepSize:signalLength
  binArr = zeros(Int64, length(signalSteps), length(fields))

  # binArr = [0 for i in eachindex(fields)]
  # binArr = [zeros(length(signalSteps)) for i in eachindex(fields)]
  for fx in eachindex(fields)
    fk = fields[fx]

    # purge missing records on all columns
    toSupress = begin
      [ismissing(xDf[fk][j, i]) for j in 1:size(xDf[fk], 1) for i in 1:size(xDf[fk], 2)] |>
      p -> reshape(p, size(xDf[fk], 2), size(xDf[fk], 1)) |>
      p -> sum(p, dims = 1)
    end

    delete!(xDf[fk], (toSupress' .== size(xDf[fk], 2))[:, 1])

    # generate signal holder
    signalVec = zeros(signalLength)

    # collect annotations
    for ix in 1:size(xDf[fk], 1)
      if !ismissing(xDf[fk][ix, :START]) & !ismissing(xDf[fk][ix, :END])
        emSt = xDf[fk][ix, :START] - startTime |> p -> convert(Dates.Second, p) |> p -> p.value * recFreq
        emEn = xDf[fk][ix, :END] - startTime |> p -> convert(Dates.Second, p) |> (p -> p.value * recFreq) + recFreq
        signalVec[emSt:emEn, :] .= 1
      else
        @warn "Annotation is not formatted properly & is not reliable"
      end
    end

    # binned signal
    binVec = begin
      binVec = extractChannelSignalBin(signalVec, binSize = binSize, binOverlap = binOverlap)
      binVec = sum(binVec, dims = 2)
      replace!(r -> r >= 1 ? 1 : 0, binVec)
      binVec = convert.(Int64, binVec)
      binVec[:, 1]
    end
    binArr[:, fx] = binVec
  end

  return binArr
end

################################################################################

"""

    labelParser(lbAr)

Parse three-column array into binary encoding

"""
function labelParser(lbAr::Matrix{Int64})
  @info "Parsing annotations..."
  lbSz = size(lbAr, 1)
  tmpAr = Array{String}(undef, lbSz, 1)
  for ix in 1:lbSz
    tmpAr[ix, 1] = string(lbAr[ix,  1], lbAr[ix, 2], lbAr[ix, 3], )
  end
  outAr = parse.(Int64, tmpAr, base = 2)
  outAr = reshape(outAr, (size(outAr, 1), ))
  return outAr
end

################################################################################

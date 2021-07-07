################################################################################

"""

    getSignals(shParams::Dict)

# Description
Read EDF file from shell arguments. Return dataframe of signals.

"""
function getSignals(shParams::Dict)
  if haskey(shParams, "indir") && haskey(shParams, "file")
    return getSignals( string(shParams["indir"], shParams["file"]) )
  else
    @error "Variables are not defined in dictionary"
  end
end

################################################################################

"""

    getSignals(edfFile::String)

# Description
Read EDF file. Return dataframe of signals.

"""
function getSignals(edfFile::String)
  # read edf file
  @info "Reading EDF file..."
  edfRecord = EDF.read(edfFile)

  # load signals
  edfDf = DataFrames.DataFrame()
  signalLength = length(edfRecord.signals)

  for ι ∈ 1:signalLength
    try
      if edfRecord.signals[ι].header.label ∉ ["A", "MK", "ECG", "EKG"]
        edfDf[!, edfRecord.signals[ι].header.label] = EDF.decode(edfRecord.signals[ι])
      end
    catch
      # no catch
    end
  end

  #  collect record frecuency
  recordFreq = getedfRecordFreq(edfRecord)

  # collect timestamp
  startTime = getedfStart(edfRecord)

  return edfDf, startTime, recordFreq
end

################################################################################

"obtain start time"
function getedfStart(edfRecord)
  # collect timestamp
  startTime = edfRecord.header.start |> Dates.Time
end

################################################################################

"obtain record frequency"
function getedfRecordFreq(edfRecord)
  # collect recording frecuency
  signalLength = length(edfRecord.signals)

  recordFreq = [edfRecord.signals[1].header.samples_per_record]
  for ι ∈ 2:signalLength
    try
      if edfRecord.signals[ι].header.label ∉ ["A", "MK", "ECG", "EKG"]
        recordFreq = [recordFreq; edfRecord.signals[ι].header.samples_per_record]
      end
    catch
      # no catch
    end
  end
  return recordFreq
end

################################################################################

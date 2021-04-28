################################################################################

import DataFrames
import Dates
import EDF

################################################################################

"""

    getSignals(edfFile)

# Description
Read EDF file & Return dataframe of signals

```

"""
function getSignals(edfFile)
  # read edf file
  @info "Reading EDF file..."
  edfRecord = EDF.read(edfFile)

  # load signals
  edfDf = DataFrames.DataFrame()
  signalLength = length(edfRecord.signals)

  for i in 1:signalLength
    try
      if edfRecord.signals[i].header.label ∉ ["A", "MK", "ECG", "EKG"]
        edfDf[!, edfRecord.signals[i].header.label] = EDF.decode(edfRecord.signals[i])
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
  for i in 2:signalLength
    try
      if edfRecord.signals[i].header.label ∉ ["A", "MK", "ECG", "EKG"]
        recordFreq = [recordFreq; edfRecord.signals[i].header.samples_per_record]
      end
    catch
      # no catch
    end
  end
  return recordFreq
end

################################################################################

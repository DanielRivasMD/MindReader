################################################################################

import DataFrames
import Dates
import EDF

################################################################################

"""

    getSignals(edfFile)

# Description
Read EDF file & Return dataframe of signals

# Usage

# Example
```julia-repl
julia> getSignals("file.edf")
100×19 DataFrame
│ Row │ 1      │ 2     │ 3      │ 4     │ 5     │ 6     │ 7     │ 8     │ 9      │ 10    │ 11    │ 12     │ 13    │ 14     │ 15    │ 16    │ 17    │ 18    │ 19    │
│     │ Int16  │ Int16 │ Int16  │ Int16 │ Int16 │ Int16 │ Int16 │ Int16 │ Int16  │ Int16 │ Int16 │ Int16  │ Int16 │ Int16  │ Int16 │ Int16 │ Int16 │ Int16 │ Int16 │
├─────┼────────┼───────┼────────┼───────┼───────┼───────┼───────┼───────┼────────┼───────┼───────┼────────┼───────┼────────┼───────┼───────┼───────┼───────┼───────┤
│ 1   │ -8021  │ -4868 │ -744   │ 5961  │ 2740  │ 1944  │ 2930  │ 1553  │ -2260  │ 368   │ 3634  │ -8360  │ 855   │ -9504  │ 5049  │ 6645  │ 759   │ 3612  │ 5537  │
│ 2   │ -9631  │ -581  │ -3047  │ 6577  │ 3919  │ 562   │ 3107  │ 1670  │ -2881  │ -615  │ 5016  │ -8865  │ 2065  │ -12635 │ 3501  │ 6622  │ -544  │ 2404  │ 7030  │
│ 3   │ -9763  │ 3692  │ -4191  │ 8247  │ 11163 │ -145  │ 4395  │ 5569  │ -4829  │ -2493 │ 2949  │ -10542 │ 1938  │ -12800 │ 3590  │ 5283  │ -3870 │ -1033 │ 5784  │
│ 4   │ -8749  │ 4454  │ -5699  │ 10650 │ 21745 │ -114  │ 6728  │ 11426 │ -7902  │ -4697 │ -2133 │ -13065 │ 247   │ -9246  │ 6244  │ 4780  │ -7289 │ -4195 │ 2557  │
│ 5   │ -10115 │ 334   │ -8021  │ 10895 │ 24243 │ -129  │ 8514  │ 14081 │ -10396 │ -5946 │ -3212 │ -14661 │ -620  │ -8861  │ 9052  │ 7639  │ -7990 │ -1578 │ 4669  │
⋮
│ 96  │ -14372 │ -5037 │ -9221  │ 8160  │ 16289 │ 117   │ 9399  │ 12487 │ -10794 │ -5519 │ 2648  │ -14506 │ 731   │ -14404 │ 8278  │ 12385 │ -6154 │ 4516  │ 12150 │
│ 97  │ -16589 │ -5914 │ -9743  │ 6113  │ 11643 │ 756   │ 10669 │ 10890 │ -10205 │ -4346 │ 6962  │ -13744 │ 1701  │ -16777 │ 6085  │ 14105 │ -4659 │ 5600  │ 13675 │
│ 98  │ -14447 │ -2561 │ -11499 │ 6578  │ 16271 │ 623   │ 11937 │ 11726 │ -10532 │ -3695 │ 3870  │ -13469 │ 154   │ -10927 │ 7491  │ 11655 │ -4358 │ 2243  │ 6573  │
│ 99  │ -12618 │ -1515 │ -12941 │ 6056  │ 16372 │ -675  │ 11097 │ 12476 │ -11193 │ -3451 │ 1387  │ -13385 │ -1322 │ -6845  │ 10596 │ 10047 │ -2952 │ 3958  │ 4067  │
│ 100 │ -14624 │ -4936 │ -12160 │ 2962  │ 4781  │ -1818 │ 8517  │ 10874 │ -10750 │ -3047 │ 6629  │ -13046 │ -3    │ -11832 │ 9633  │ 12612 │ 287   │ 11512 │ 11876 │

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

function getedfStart(edfRecord)
  # collect timestamp
  startTime = edfRecord.header.start |> Dates.Time
end

################################################################################

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

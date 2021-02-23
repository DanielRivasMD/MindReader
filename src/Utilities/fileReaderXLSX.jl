################################################################################

import XLSX

################################################################################

"""

    xread(xlsxFile)

# Description
Read annotation XLSX file

# Usage

# Example
```
```

"""
function xread(xlsxFile)
  # read xlsx file
  @info("Reading XLSX file...")
  xtmp = XLSX.readxlsx(xlsxFile)

  if xtmp |> XLSX.sheetcount != 3
    @error "Annotations file $(xlsxFile) does not contain 3 sheets"
  end

  # load sheets on dataframes
  outDc = Dict()
  kys = ["PD" 7; "SA" 6; "EM" 4]
  for (k, s) in eachrow(kys)
    j = (match.(Regex(k), xtmp |> XLSX.sheetnames) .|> !isnothing |> findall)[1]
    xar = xtmp[j][:]
    if size(xar, 2) == s + 1
      if k == "EM" && ismissing(xar[1, end - 1])
        xar[1, end - 1] = xar[1, end]
      end
      xar[1, end] = "ADDITIONAL"
    else
      xar = [xar ["ADDITIONAL"; repeat([missing], size(xar, 1) - 1)]]
    end
    xAr = xar[2:end, :] |> DataFrame
    for ix in 1:size(xar, 2)
      rename!(xAr, [ix => xar[1, ix]])
    end
    if k == "SA"
      outDc["ST"] = xAr[:, 1:3]
      outDc["MA"] = xAr[:, 4:end]
      for kx in ["ST", "MA"]
        for ix in 2:3
          rename!(outDc[kx], [ix => replace.(names(outDc[kx])[ix], r"\S " => "")])
        end
      end
    else
      outDc[k] = xAr
    end
  end

  return outDc
end

################################################################################

################################################################################









  end

  @info "Plotting..."
  # create array to plot



  @info "Rendering..."

end

################################################################################

""
function plotChannelsHeatmap(outdir::String, outsvg::String, toHeat::Array{Float64, 2})
#  TODO: add channel labels by passing vector to heatmap function
  # plot layout
  plotFig = CairoMakie.Figure()
  heatplot = plotFig[1, 1] = CairoMakie.Axis(plotFig, title = "States Heatmap")

  # axis labels
  heatplot.xlabel = "Recording Time"
  heatplot.ylabel = "Channels"
  # heatplot.yticks = 1:22

  # heatmap plot & color range
  hm = CairoMakie.heatmap!(heatplot, toHeat')
  hm.colorrange = (0, 5)

  # color bar
  cbar = plotFig[2, 1] = CairoMakie.Colorbar(plotFig, hm, label = "HMM states")
  cbar.vertical = false
  cbar.height = 10
  cbar.width = CairoMakie.Relative(2 / 3)
  cbar.ticks = 1:1:5

  # save rendering
  CairoMakie.save( string(outdir, outsvg), plotFig )

################################################################################

"iterate over known electrodes and collect states from Hidden Markov model"
function collectState(modelHMM::Dict{S, Tuple{Array{T, 1}, Array{Array{U, 1}, 1}}}, electrodes::Array{S}) where S <: String where T <: Int64 where U <: Float64

  keyString = modelHMM[convert.(String, keys(modelHMM))[1]][1]
  toHeat = zeros(length(modelHMM), length(keyString))
  ψ = size(toHeat, 1)
  for ε ∈ electrodes
    if haskey(modelHMM, ε)
      toHeat[ψ, :] = modelHMM[ε][1]
      ψ -= 1
    else
      @debug ε
    end
  end
  return toHeat, keyString
end

################################################################################

function shChecker(shArgs, ky, suffix)
  if shArgs[ky] != nothing
    return shArgs[ky]
  else
    return replace(shArgs["file"], "edf" => suffix)
  end
end

################################################################################

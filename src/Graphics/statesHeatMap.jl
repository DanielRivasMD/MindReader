################################################################################

"""

  mindGraphics(modelHMM::Dict{S, Tuple{Array{T, 1}, Array{Array{U, 1}, 1}}}, shArgs::Dict;
  labels = nothing) where S <: String where T <: Int64 where U <: Float64

# Description
Control graphic module of *MindReader*. Verifies arguments, builds heatmap, write to file and renders image.

# Arguments
`modelHMM` model to render by graphics module.

`shArgs` shell arguments.

if available `labels` are available, concatenate to rendering.


"""
function mindGraphics(modelHMM::Dict{S, Tuple{Array{T, 1}, Array{Array{U, 1}, 1}}}, shArgs::Dict; labels = nothing) where S <: String where T <: Int64 where U <: Float64

  # check arguments | assign
  κ = [:svg, :csv]
  for (ζ, ξ) ∈ zip([Symbol("out", ι) for ι ∈ κ], κ)
    τ = shChecker(shArgs, string(ζ), string(ξ))
    @eval $ζ = $τ
  end

  @info "Plotting..."
  # create array to plot
  toHeat, keyString = collectState(modelHMM)

  if !isnothing(labels)
    # concatenate annotations
    toHeat = [toHeat; labels' .+ 1]
  end

  # write
  writedlm( string(shArgs["outdir"], outcsv), toHeat, "," )

  @info "Rendering..."
  renderGraphics( string(shArgs["outdir"], outsvg), toHeat )

end

################################################################################

"wrapper for model heatmap plotting"
function renderGraphics(filename::S, toHeat::Array{T, 2}) where S <: String where T <: Number

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
  CairoMakie.save( filename, plotFig )

end

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

"check whether shell argument was explicitly declared and assigned"
function shChecker(shArgs::Dict, κ::S, ζ::S) where S <: String
  if shArgs[κ] != nothing
    return shArgs[κ]
  else
    return replace(shArgs["file"], "edf" => ζ)
  end
end

################################################################################

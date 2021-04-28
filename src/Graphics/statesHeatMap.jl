################################################################################

import CairoMakie
import DelimitedFiles

################################################################################

""
function runHeatmap(outimg::String, outsvg::String, outcsv::String, inDc::Dict{String, Tuple{Array{Int64, 1}, Array{Array{Float64, 1}, 1}}})

  @info "Plotting..."
  # create array to plot
  toHeat, keyString = collectState(inDc)

  # collect stats & write
  stats = stateStats(toHeat)
  DelimitedFiles.writedlm( string(outcsv, outimg, "Raw.csv"), stats, ", " ) #  hardcoded csv directory
  #  DelimitedFiles.writedlm(string(outdir, "/", outimg, ".csv"), stats, ", ")

  # # add label tracks
  # for ix in 1:size(labelAr, 2)
  #   toHeat[ix, :] .= labelAr[1:size(toHeat, 2), ix]
  # end

  @info "Rendering..."
  plotChannelsHeatmap(outimg, outsvg, toHeat)

end

################################################################################

""
function runHeatmap(outimg::String, outsvg::String, outcsv::String, inDc::Dict{String, Tuple{Array{Int64, 1}, Array{Array{Float64, 1}, 1}}}, lbAr::Array{Int64, 2})

  @info "Plotting..."
  # create array to plot
  toHeat, keyString = collectState(inDc)

  # concatenate annotations
  toHeat = [toHeat; lbAr' .+ 1]

  # collect stats & write
  stats = stateStats(toHeat)
  DelimitedFiles.writedlm( string(outcsv, outimg, "Lab.csv"), stats, ", " ) #  hardcoded csv directory
  #  DelimitedFiles.writedlm(string(outdir, "/", outimg, ".csv"), stats, ", ")

  # # add label tracks
  # for ix in 1:size(labelAr, 2)
  #   toHeat[ix, :] .= labelAr[1:size(toHeat, 2), ix]
  # end

  @info "Rendering..."
  plotChannelsHeatmap(outimg, outsvg, toHeat)

end

################################################################################

""
function plotChannelsHeatmap(outimg::String, outsvg::String, toHeat::Array{Float64, 2})
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
  CairoMakie.save( string(outsvg, outimg, ".svg"), plotFig )

end

################################################################################

################################################################################

using Clustering
using StatsPlots
using Distances

#  functions
utilDir = "Utilities/"
include( string("src/", utilDir,  "stateStats.jl") );

outdir = "./" #  output

#  collect stats
csvList = readdir("csv/")
colStats = summarizeStats( string.("csv/", csvList) )

#  purge brain death records
colStats = colStats[[1:50; 54:99], :]

#  calculate pairwise by Euclidean distance
pwAr = pairwise(Euclidean(), colStats, dims = 1)

#  hierarchical clustering
hcl = hclust(pwAr)

#  plot heatmap + top dendrogram
plot(
  plot(hcl, xticks=false),
  heatmap(colStats[hcl.order, :], colorbar = false, ),
  layout = grid(2,1, heights = [0.2,0.8])
)


################################################################################

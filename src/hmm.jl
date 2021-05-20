#
# using DelimitedFiles
#
# x = readdlm("/Users/drivas/Factorem/electrosignals/mentes/freq_0")[:, 2:end] |> p -> convert.(Float64, p)
# mPen, hmm = setup(x)
# process(hmm, x, mPen, true)
#
# # setup
# mPen, hmm = setup(x)
#
# # process
# for i in 1:4
#   errDc[k] = process(hmm, x, mPen, true)
# end
# errDc[k] = process(hmm, x, mPen, false)


################################################################################

utilDir = "/Users/drivas/Factorem/electrosignals/utilitiesJL/"
localDir = "/Users/drivas/Factorem/MindReader/src/HiddenMarkovModel/"
include(string(utilDir, "EHMMargParser.jl"))

# parse shell arguments
shArgs = shArgParser(ARGS)

begin
  file = shArgs["file"]
  outDir = string(shArgs["output"], "/")
end;

################################################################################

# load functions
include(string(utilDir, "EHMMReader.jl"))
# include(string(utilDir, "EHMM.jl"))
include(string(localDir, "hiddenMarkovModel.jl"))

################################################################################

# localDir = "/Users/drivas/Factorem/MindReader/src/HiddenMarkovModel/"
# include(string(localDir, "hiddenMarkovModel.jl"))
# file = "/Users/drivas/Factorem/electrosignals/mentes/back0"
#
# using DelimitedFiles
#
# v = readdlm(file)
#
# mPen, hmm = setup(v)
#
# self = hmm
# d = v
# pen = mPen
# splitSw = false


################################################################################

# setup
mPen, hmm = setup(v)
# mPen = 5000.
# noIter = 1
# hmm = EHMM([zeros(size(v, 2)) for i in 1:noIter], [zeros(size(v, 1) + 1) for i in 1:noIter])
# reset!(hmm)

################################################################################

# process
for i in 1:4
  process(hmm, v, mPen, true)
end
process(hmm, v, mPen, false)

@info "FINAL"
process(hmm, v, mPen, false)
@info "DONE"

################################################################################

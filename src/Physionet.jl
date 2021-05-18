################################################################################

# module MindReader
#  TODO: update function docs & purge for MindReader

################################################################################

import Pkg: activate
activate("../")

################################################################################

import Parameters: @with_kw

# set hyperparameters
@with_kw mutable struct Params
  η::Float64                   = 1e-3     # learning rate
  epochs::Int                  = 10       # number of epochs
  batchsize::Int               = 1000     # batch size for training
  throttle::Int                = 5        # throttle timeout
  device::Function             = gpu      # set as gpu, if gpu available
end;

################################################################################

#  argument parser
# include( "Utilities/argParser.jl" );

################################################################################

#  function main()

###############################################################################

#  declare tool directories
begin
  utilDir    = "Utilities/"
  montageDir = "Montage/"
  annotDir   = "Annotator/"
  signalDir  = "SignalProcessing/"
  arqDir     = "Architect/"
  hmmDir     = "HiddenMarkovModel/"
  pcaDir     = "PrincipalComponentAnalysis/"
  imgDir     = "ImageProcessing/"
  graphDir   = "Graphics/"
  performDir = "Performance/"
end;

################################################################################

#  load functions
begin
  @info("Loading modules...")
  include( string(utilDir,    "fileReaderEDF.jl") )
  include( string(montageDir, "electrodeID.jl") )
  include( string(performDir, "stateStats.jl") )
  include( string(annotDir,   "fileReaderXLSX.jl") )
  include( string(annotDir,   "annotationCalibrator.jl") )
  include( string(signalDir,  "signalBin.jl") )
  include( string(signalDir,  "fastFourierTransform.jl") )
  include( string(hmmDir,     "hiddenMarkovModel.jl") )
  include( string(arqDir,     "architect.jl") )
  include( string(arqDir,     "shapeShifter.jl") )
  include( string(arqDir,     "autoencoder.jl") )
  # include( string(arqDir,     "SMPerceptron.jl") )
  include( string(graphDir,   "statesHeatMap.jl") )
  include( string(performDir, "screening.jl") )
  include( string(performDir, "permutations.jl") )
  include( string(utilDir,    "writeCSV.jl") )
end;

################################################################################

outsvg = "/Users/drivas/Factorem/MindReader/data/svg/"
outcsv = "/Users/drivas/Factorem/MindReader/data/csv/"
outscreen = "/Users/drivas/Factorem/MindReader/data/screen/"
outhmm = "/Users/drivas/Factorem/MindReader/data/hmm/"

dir = "/Users/drivas/Factorem/EEG/data/physionet.org/files/chbmit/1.0.0/chb04/"
xfile = "chb04-summary.txt"
# file = "chb04_28.edf"

winBin = 256
overlap = 4

annotFile = annotationReader( string(dir, xfile) )

################################################################################

dirRead = readdir(dir)
fileList = contains.(dirRead, r"edf$") |> p -> getindex(dirRead, p)

for file in fileList

  @info file
  outimg = replace(file, ".edf" => "")

  #  read data
  begin
    # read edf file
    edfDf, startTime, recordFreq = getSignals( string(dir, file) )

    # # read xlsx file
    # xfile = replace(file, "edf" => "xlsx")
    # xDf = xread(xfile)

    if haskey(annotFile, outimg)

      labelAr = annotationCalibrator(
        annotFile[outimg],
        startTime = startTime,
        recordFreq = recordFreq,
        signalLength = size(edfDf, 1),
        binSize = winBin,
        binOverlap = overlap
      )

    end

    # # labels array
    # labelAr = annotationCalibrator(
      # xDf,
      # startTime = startTime,
      # recordFreq = recordFreq,
      # signalLength = size(edfDf, 1),
      # binSize = winBin,
      # binOverlap = overlap
    # )

    # calculate fft
    freqDc = extractChannelFFT(edfDf, binSize = winBin, binOverlap = overlap)
  end;

  ################################################################################

  # build autoencoder & train hidden Markov model
  begin
    for d in [Symbol(i, "Dc") for i = [:err, :post, :comp]]
      @eval $d = Dict{String, Tuple{Array{Int64, 1}, Array{Array{Float64, 1}, 1}}}()
    end

    # TODO: check errors. Array
    # ssDc = Dict()
    for (k, f) in freqDc
      println()
      @info k
      # ssDc[k] = Dict()

      #  build & train autoencoder
      freqAr = shifter(f)
      # model = buildDeepRecurrentAutoencoder(length(freqAr[1]), 100, leakyrelu)
      # model = buildRecurrentAutoencoder(length(freqAr[1]), 100, leakyrelu)
      model = buildAutoencoder(length(freqAr[1]), 100, leakyrelu)
      model = modelTrain(freqAr, model, Params)

      ################################################################################

      #  # post
      postAr = cpu(model).(freqAr)
      #  aPos = reshifter(postAr) |> p -> Flux.flatten(p)
      #
      #  # setup
      #  mPen, hmm = setup(aPos)
      #  # process
      #  for i in 1:5
      #    postDc[k] = process(hmm, aPos, mPen)
      #  end
      #
      #  # # calculate sensitivity & specificity
      #  # ssDc[k]['P'] = sensspec(postDc[k][1], labelAr)

      ################################################################################

      begin
        @info "Creating Hidden Markov Model..."
        # error
        aErr = reshifter(postAr - freqAr) |> p -> Flux.flatten(p) |> permutedims

        # setup
        mPen, hmm = setup(aErr)

        # process
        for i in 1:4
          errDc[k] = process(hmm, aErr, mPen, true)
        end

        # final
        for i in 1:2
          errDc[k] = process(hmm, aErr, mPen, false)
        end
      end;


      # # calculate sensitivity & specificity
      # ssDc[k]['E'] = sensspec(errDc[k][1], labelAr)

      ################################################################################

      #  # compressed
      #  compAr = cpu(model[1]).(freqAr)
      #  aComp = reshifter(compAr, length(compAr[1])) |> p -> Flux.flatten(p)
      #
      #  # setup
      #  mPen, hmm = setup(aComp)
      #  # process
      #  for i in 1:5
      #    compDc[k] = process(hmm, aComp, mPen)
      #  end
      #
      #  # # calculate sensitivity & specificity
      #  # ssDc[k]['C'] = sensspec(compDc[k][1], labelAr)

      ################################################################################

    end
  end;

  ################################################################################

  if haskey(annotFile, outimg)

    scr = sensspec(errDc, labelAr)

    # permut = rdPerm(errDc, labelAr, weighted = false)
    # perWeg = rdPerm(errDc, labelAr, weighted = true)

    DelimitedFiles.writedlm( string(outscreen, outimg, ".csv"), writePerformance(scr), ", " )

    # DelimitedFiles.writedlm(string("permutation/U", outimg, ".csv"), toArray(permut), ", ")
    # DelimitedFiles.writedlm(string("permutation/W", outimg, ".csv"), toArray(perWeg), ", ")

    ################################################################################

    # runHeatmap(errDc)

    runHeatmap(outimg, outsvg, outcsv, errDc, labelAr)

  else

    runHeatmap(outimg, outsvg, outcsv, errDc)

  end

  ################################################################################

  writeHMM( string(outhmm, replace(file, ".edf" => "_")), errDc)

  ################################################################################

end

################################################################################

# end

################################################################################

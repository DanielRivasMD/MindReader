################################################################################

# if CUDAapi.has_cuda()
  # # @info "CUDA is on"
  # import CuArrays
  # CuArrays.allowscalar(false)
# end

################################################################################

"""

    modelTrain!(model, inputAr;
    nnParams)

# Description
Train autoencoder.

# Arguments
`inputAr` array to train on.

`model` neural network architecture.

arguments passed as `nnParams` with `Parameters::@with_kw`


See also: [`buildAutoencoder`](@ref)
"""
function modelTrain!(model, inputAr; nnParams)
  args = nnParams()

  @info("Loading data...")
  trainAr = args.device.(inputAr)

  @info("Training model...")
  loss(χ) = mse(model(χ), χ)

  # training
  evalcb = throttle(() -> @show(loss(trainAr[1])), args.throttle)
  opt = ADAM(args.η)

  @epochs args.epochs train!(loss, params(model), zip(trainAr), opt, cb = evalcb)

end

################################################################################

################################################################################

import Flux: mse, throttle, ADAM
import Parameters: @with_kw
# import CUDAapi

################################################################################

# if CUDAapi.has_cuda()
  # # @info "CUDA is on"
  # import CuArrays
  # CuArrays.allowscalar(false)
# end

################################################################################

"""

    modelTrain(inputAr, model, Params;
    kws...)

Train autoencoder

# Arguments
`inputAr` array to train on

`model` neural network architecture

arguments passed as `Params` with `Parameters::@with_kw`

"""
function modelTrain(inputAr, model, Params)
  args = Params()

  @info("Loading data...")
  trainAr = args.device.(inputAr)

  @info("Training model...")
  loss(x) = Flux.mse(model(x), x)

  # training
  evalcb = Flux.throttle(() -> @show(Flux.loss(trainAr[1])), args.throttle)
  opt = Flux.ADAM(args.η)

  # @epochs args.epochs Flux.train!(loss, params(model), zip(trainAr), opt, cb = evalcb)

  return model
end

################################################################################

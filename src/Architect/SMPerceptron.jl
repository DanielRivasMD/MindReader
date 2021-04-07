################################################################################

import Flux.Data: DataLoader
import Flux: onehotbatch, onecold, logitcrossentropy, throttle, @epochs
import Parameters: @with_kw
# import CUDAapi

################################################################################

# if CUDAapi.has_cuda()
  # @info "CUDA is on"
  # import CuArrays
  # CuArrays.allowscalar(false)
# end

################################################################################

"""

    loadData(dataAr, labelAr, args;
    shuffle = false)

Data loader to neural network trainer

"""
function loadData(dataAr, labelAr, args; shuffle = false)

  # one-hot-encode the labels
  labelAr = Flux.onehotbatch(labelAr, args.labels)

  # batching
  dataAr = Flux.Data.DataLoader((dataAr, labelAr), batchsize = args.batchsize, shuffle = shuffle)

  return dataAr
end

################################################################################

"""

    loss_all(dataloader, model)

Calculate loss during training

"""
function loss_all(dataloader, model)
  l = 0f0
  for (x ,y) in dataloader
    l += Flux.logitcrossentropy(model(x), y)
  end
  l / length(dataloader)
end

################################################################################

"""

    accuracy(data_loader, model)

Estimate model accuracy

"""
function accuracy(data_loader, model)
  acc = 0
  for (x, y) in data_loader
    acc += sum(Flux.onecold(cpu(model(x))) .== Flux.onecold(cpu(y))) * 1 / size(x, 2)
  end
  acc / length(data_loader)
end

################################################################################

"""

    modelTrain(inputAr, labelAr, model, Params;
    kws...)

Train simple multilayer perceptron

# Arguments
`inputAr` array to train on

`labelAr` labeled array

`model` neural network architecture

arguments passed as `Params` with `Parameters::@with_kw`

"""
function modelTrain(inputAr, labelAr, model, Params)
  args = Params()

  @info("Loading data...")
  trainAr = loadData(inputAr, labelAr, args, shuffle = true)
  trainAr = args.device.(trainAr)

  @info("Training model...")
  model = args.device(model)
  loss(x, y) = Flux.logitcrossentropy(model(x), y)

  # training
  evalcb = () -> @show(loss_all(trainAr, model))
  opt = Flux.ADAM(args.η)

  Flux.@epochs args.epochs Flux.train!(loss, Flux.params(model), trainAr, opt, cb = evalcb)

  @show accuracy(trainAr, model)

  return model
end

################################################################################

"""

    modelTest(inputAr, labelAr, model, Params;
    kws...)

Train simple multilayer perceptron

# Arguments
`inputAr` array to test

`labelAr` labeled array

`model` neural network architecture

"""
function modelTest(inputAr, labelAr, model, Params)
  args = Params()

  @info("Loading data...")
  testAr = loadData(inputAr, labelAr, args)
  testAr = args.device.(testAr)

  @show accuracy(testAr, model)

end

################################################################################

function modelSS(inputAr, labelAr, model, Params)
  args = Params()

  @info("Loading data...")
  testAr = loadData(inputAr, labelAr, args)
  # testAr = args.device.(testAr)

  return sensspec(testAr, model)

end

################################################################################

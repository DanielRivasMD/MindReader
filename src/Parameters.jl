################################################################################

import Parameters: @with_kw

# set hyperparameters
@with_kw mutable struct NNParams
  η::Float64                   = 1e-3             # learning rate
  epochs::Int                  = 10               # number of epochs
  batchsize::Int               = 1000             # batch size for training
  throttle::Int                = 5                # throttle timeout
  device::Function             = Flux.gpu         # set as gpu, if gpu available
  σ::Function                  = Flux.leakyrelu   # learning function
  autoencoderHiddenLayer::Int  = 100              # hidden layer on autoencoder
end;

################################################################################

import HiddenMarkovModelReaders: HMMParams

# hidden Markov model parameters
hmmParams = HMMParams(pen = 200., distance = euclDist)

################################################################################

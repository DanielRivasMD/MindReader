####################################################################################################

# three-layered autoencoder
"""

    buildAutoencoder(inputLayer::I;
    nnParams)
    where I <: Integer

# Description
Build a three-layered autoencoder.

# Arguments
`inputLayer` number of neurons on input.

`nnParams` neural network hyperparameters.


See also: [`modelTrain!`](@ref)
"""
function buildAutoencoder(inputLayer::I; nnParams) where I <: Integer
  @info("Building three-layered autoencoder...")
  args = nnParams()
  return Chain(
    Dense(inputLayer, args.λ, args.σ),
    Dense(args.λ, inputLayer, args.σ),
  )
end

####################################################################################################

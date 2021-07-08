################################################################################

function buildDeepRecurrentAutoencoder(inputLayer::Integer, compressedLayer::Integer, σ)
  @info("Building deep recurrent autoencoder...")
  return Flux.Chain(
    Flux.LSTM(inputLayer, convert(Int64, inputLayer - 20)),
    Flux.LSTM(convert(Int64, inputLayer - 20), convert(Int64, inputLayer - 40)),
    Flux.LSTM(convert(Int64, inputLayer - 40), convert(Int64, inputLayer - 60)),
    Flux.LSTM(convert(Int64, inputLayer - 60), compressedLayer),
    Flux.LSTM(compressedLayer, convert(Int64, inputLayer - 60)),
    Flux.LSTM(convert(Int64, inputLayer - 60), convert(Int64, inputLayer - 40)),
    Flux.LSTM(convert(Int64, inputLayer - 40), convert(Int64, inputLayer - 20)),
    Flux.LSTM(convert(Int64, inputLayer - 20), inputLayer),
  )
end

################################################################################

# three-layered autoencoder
"""

    buildAutoencoder(inputLayer::T;
    nnParams) where T <: Integer

# Description
Build a three-layered autoencoder

# Arguments
`inputLayer` number of neurons on input.

`nnParams` neural network hyperparameters.


See also: [`modelTrain!`](@ref)
"""
function buildAutoencoder(inputLayer::T; nnParams) where T <: Integer
  @info("Building three-layered autoencoder...")
  args = nnParams()
  return Flux.Chain(
  )
end

################################################################################

# four-layered assymetrical autoencoder
"""

    buildAssymmetricalAutoencoder(inputLayer, assymetricalLayer1, assymetricalLayer2, σ)

Build a four-layered assymetrical autoencoder

# Arguments
`inputLayer` number of neurons on input

`assymetricalLayer1` number of neurons on assymetrical layer 1

`assymetricalLayer2` number of neurons on assymetrical layer 2

`σ` layer identity

"""
function buildAssymmetricalAutoencoder(inputLayer::Integer, assymetricalLayer1::Integer, assymetricalLayer2::Integer, σ)
  @info("Building four-layered assymetrical autoencoder...")
  return Flux.Chain(
    Flux.Dense(inputLayer, assymetricalLayer1, σ),
    Flux.Dense(assymetricalLayer1, assymetricalLayer2, σ),
    Flux.Dense(assymetricalLayer2, inputLayer, σ),
  )
end

################################################################################

# three-layered recurrent autoencoder
"""

    buildRecurrentAutoencoder(inputLayer, compressedLayer, σ)

Build a three-layered recurrent autoencoder

# Arguments
`inputLayer` number of neurons on input

`compressedLayer` number of neurons on inner compression layer

`σ` layer identity

"""
function buildRecurrentAutoencoder(inputLayer::Integer, compressedLayer::Integer, σ)
  @info("Building three-layered recurrent autoencoder...")
  return Flux.Chain(
    Flux.LSTM(inputLayer, compressedLayer),
    Flux.Dense(compressedLayer, inputLayer, σ),
  )
end

################################################################################

# five-layered autoencoder
"""

    buildAutoencoder(inputLayer, innerLayer1, compressedLayer, σ)

Build a five-layered autoencoder

# Arguments
`inputLayer` number of neurons on input

`innerLayer1` number of neurons on first compression layer

`compressedLayer` number of neurons on inner compression layer

`σ` layer identity

"""
function buildAutoencoder(inputLayer::Integer, innerLayer1::Integer, compressedLayer::Integer, σ)
  @info("Building five-layered autoencoder...")
  return Flux.Chain(
    Flux.Dense(inputLayer, innerLayer1, σ),
    Flux.Dense(innerLayer1, compressedLayer, σ),
    Flux.Dense(compressedLayer, innerLayer1, σ),
    Flux.Dense(innerLayer1, inputLayer, σ),
  )
end

################################################################################

# five-layered assymetrical autoencoder
"""

    buildAssymmetricalAutoencoder(inputLayer, innerLayer1, compressedLayer, σ)

Build a five-layered assymetrical autoencoder

# Arguments
`inputLayer` number of neurons on input

`assymetricalLayer1` number of neurons on assymetrical layer 1

`assymetricalLayer2` number of neurons on assymetrical layer 2

`assymetricalLayer3` number of neurons on assymetrical layer 3

`σ` layer identity

"""
function buildAssymmetricalAutoencoder(inputLayer::Integer, assymetricalLayer1::Integer, assymetricalLayer2::Integer, assymetricalLayer3::Integer, σ)
  @info("Building five-layered autoencoder...")
  return Flux.Chain(
    Flux.Dense(inputLayer, assymetricalLayer1, σ),
    Flux.Dense(assymetricalLayer1, assymetricalLayer2, σ),
    Flux.Dense(assymetricalLayer2, assymetricalLayer3, σ),
    Flux.Dense(assymetricalLayer3, inputLayer, σ),
  )
end

################################################################################

# five-layered recurrent autoencoder
"""

    buildRecurrentAutoencoder(inputLayer, innerLayer1, compressedLayer, σ)

Build a five-layered recurrent autoencoder

# Arguments
`inputLayer` number of neurons on input

`innerLayer1` number of neurons on first compression layer

`compressedLayer` number of neurons on inner compression layer

`σ` layer identity

"""
function buildRecurrentAutoencoder(inputLayer::Integer, innerLayer1::Integer, compressedLayer::Integer, σ)
  @info("Building five-layered recurrent autoencoder...")
  return Flux.Chain(
    Flux.LSTM(inputLayer, innerLayer1),
    Flux.LSTM(innerLayer1, compressedLayer),
    Flux.LSTM(compressedLayer, innerLayer1),
    Flux.Dense(innerLayer1, inputLayer, σ),
  )
end

################################################################################

# two-layered perceptron
"""

    buildPerceptron(inputLayer, Params, σ)

Build a two-layered simple perceptron

# Arguments
`inputLayer` number of neurons on input

`σ` layer identity

arguments passed as `Params` with `Parameters::@with_kw`

"""
function buildPerceptron(inputLayer::Integer, Params, σ)
  args = Params()

  @info("Building two-layered simple perceptron...")
  return Flux.Chain(
    Flux.Dense(inputLayer, (args.labels |> length), σ),
  )
end

################################################################################

# three-layered perceptron
"""

    buildPerceptron(inputLayer, perceptronLayer1, Params, σ)

Build a three-layered simple perceptron

# Arguments
`inputLayer` number of neurons on input

`perceptronLayer1` number of neurons on first perceptron layer

`σ` layer identity

arguments passed as `Params` with `Parameters::@with_kw`

"""
function buildPerceptron(inputLayer::Integer, perceptronLayer1::Integer, Params, σ)
  args = Params()

  @info("Building three-layered simple perceptron...")
  return Flux.Chain(
    Flux.Dense(inputLayer, perceptronLayer1, σ),
    Flux.Dense(perceptronLayer1, (args.labels |> length), σ),
  )
end

################################################################################

# four-layered perceptron
"""

    buildPerceptron(inputLayer, perceptronLayer1, perceptronLayer2, Params, σ)

Build a four-layered simple perceptron

# Arguments
`inputLayer` number of neurons on input

`perceptronLayer1` number of neurons on first perceptron layer

`perceptronLayer2` number of neurons on second perceptron layer

`σ` layer identity

arguments passed as `Params` with `Parameters::@with_kw`

"""
function buildPerceptron(inputLayer::Integer, perceptronLayer1::Integer, perceptronLayer2::Integer, Params, σ)
  args = Params()

  @info("Building four-layered simple perceptron...")
  return Flux.Chain(
    Flux.Dense(inputLayer, perceptronLayer1, σ),
    Flux.Dense(perceptronLayer1, perceptronLayer2, σ),
    Flux.Dense(perceptronLayer2, (args.labels |> length), σ),
  )
end

################################################################################

# five-layered perceptron
"""

    buildPerceptron(inputLayer, perceptronLayer1, perceptronLayer2, perceptronLayer3, Params, σ)

Build a five-layered simple perceptron

# Arguments
`inputLayer` number of neurons on input

`perceptronLayer1` number of neurons on first perceptron layer

`perceptronLayer2` number of neurons on second perceptron layer

`perceptronLayer3` number of neurons on third perceptron layer

`σ` layer identity

arguments passed as `Params` with `Parameters::@with_kw`

"""
function buildPerceptron(inputLayer::Integer, perceptronLayer1::Integer, perceptronLayer2::Integer, perceptronLayer3::Integer, Params, σ)
  args = Params()

  @info("Building five-layered simple perceptron...")
  return Flux.Chain(
    Flux.Dense(inputLayer, perceptronLayer1, σ),
    Flux.Dense(perceptronLayer1, perceptronLayer2, σ),
    Flux.Dense(perceptronLayer2, perceptronLayer3, σ),
    Flux.Dense(perceptronLayer3, (args.labels |> length), σ),
    Flux.Dense(inputLayer, args.λ, args.σ),
    Flux.Dense(args.λ, inputLayer, args.σ),
  )
end

################################################################################

################################################################################

using StructArrays

################################################################################

struct ScorePair
  score::Float64
  index::Int64
end

mutable struct HMM
  dataM::Array
  tbM::Array
end

################################################################################

"sort hidden Markov model by amplitude"
function sortHMM!(self::HMM)

  ampVc = map(amplitude, self.dataM)
  sortedAmpVc = sort(ampVc)
  ampIxVc = map(sortedAmpVc) do y
   findall(x -> x == y, ampVc)
  end
  templ = Array{Array{Float64, 1}, 1}()

  for i in ampIxVc
    push!(templ, self.dataM[i[1]])
  end
  self.dataM = templ
end

################################################################################

function setup(v::Array{Float64, 2})
  mPen = 200.
  noIter = 1
  hmm = HMM([zeros(size(v, 2)) for i in 1:noIter], [zeros(size(v, 1) + 1) for i in 1:noIter])
  reset!(hmm)
  return (mPen, hmm)
end

################################################################################

function distance(self::HMM, j::Int64, h::Array{Float64, 1})
  dis = 0.
  for ix in eachindex(self.dataM[j])
    dis += (self.dataM[j][ix] - h[ix]) ^ 2
  end
  dis = sqrt(dis)
  return dis
end

function distance(arr::Array{T, 1}, h::Array{T, 1}) where T <: Number
  return (arr .- h) .^ 2  |> sum  |> sqrt
end

"Bhattacharyya distance"
function bhattDist(arr::Array{Float64, 1}, h::Array{Float64, 1})
  dis = 0.
  for ix in eachindex(arr)
    product = arr[ix] * h[ix]
    if product >= 0
      dis += sqrt(product)
    else
      @error("Product $product is less than zero")
    end
  end
  dis = -log(dis + 1.)
  return dis
end

function amplitude(arr::Array{Float64, 1})
  return arr .^ 2 |> sum |> sqrt
end

################################################################################

function reset!(self::HMM)
  self.tbM = [x .= [0; repeat(-1:-1, length(self.tbM[1]) - 1)] for x in self.tbM]
  return self.tbM
end

################################################################################

function feed(self::HMM, frame::Int64, d::Array{Float64, 2}, pen::Float64)
  for ix in eachindex(self.tbM)
    plus = distance(self, ix, d[frame, :])
    for jx in eachindex(self.tbM)
      lpen = copy(pen)
      if (jx == ix) lpen = 0 end
      if self.tbM[jx][frame + 1] < 0. || self.tbM[ix][frame] + plus + lpen < self.tbM[jx][frame + 1]
        self.tbM[jx][frame + 1] = self.tbM[ix][frame] + plus + lpen
      end
    end
  end
end

################################################################################

function backTrace(self::HMM)
  state = 0
  min = self.tbM[1][end]

  for ix in eachindex(self.tbM)
    if self.tbM[ix][end] <= min
      state = ix
      min = self.tbM[ix][end]
    end

    tb = fill(-1, size(self.tbM[1], 1))

    for ix in reverse(eachindex(self.tbM[1]))
      vlocal = min
      global sig = -1

      for jx in eachindex(self.tbM)
        dob = self.tbM[jx][ix]
        if dob <= vlocal
          vlocal = dob
          sig = jx
        end
      end

      tb[ix] = state
      state = sig

    end

    tb = tb[1:end - 1]

    return tb
  end
end

################################################################################

function process(self::HMM, d::Array{Float64, 2}, pen::Float64, splitSw::Bool)

  # reset
  reset!(self)

  # feed frame
  for ix in axes(d, 1)
    feed(self, ix, d, pen)
  end

  # backtrace
  tb = backTrace(self)

  divider = fill(1, size(self.dataM, 1))
  orig = deepcopy(self.dataM)
  pp = StructArrays.StructArray{ScorePair}(undef, 0)

  # update model
  mdist = zeros(Float64, size(self.dataM))
  mcount = zeros(Float64, size(self.dataM))

  for ix in axes(d, 1)
    self.dataM[tb[ix]] .+= d[ix, :]
    divider[tb[ix]] += 1
    # pair = ScorePair(bhattDist(orig[tb[ix]], d[ix, :]), ix) # use Bhattacharyya distance
    pair = ScorePair(distance(orig[tb[ix]], d[ix, :]), ix) # use Euclidean distance

    mdist[tb[ix]] += pair.score
    mcount[tb[ix]] += 1

    push!(pp, pair)
  end

  scores = sort(pp.score, rev = true)
  ixs = map(x -> findall(x .== pp.score), scores)
  pp = pp[vcat(ixs...)]

  for ix in eachindex(self.dataM)
    self.dataM[ix] /= divider[ix]
  end

  sortHMM!(self)

  if !splitSw
    return tb, self.dataM
  end

  max = 0.
  toSplit = 1
  minFreq = 20 # hard coded!

  for ix in eachindex(mdist)
    if mcount[ix] > minFreq
      avdist = mdist[ix] / mcount[ix]
      if avdist > max
        max = avdist
        toSplit = ix
      end
    end
  end

  half = 1 + mcount[toSplit] / 4

  extra = fill(0, size(self.dataM[1], 1))

  count = 1
  for ix in eachindex(pp)
    if tb[pp[ix].index] != toSplit
      continue
    end
    extra += d[pp[ix].index, :]
    count += 1
    if count >= half
      break
    end
  end

  extra ./= (count - 1)

  push!(self.dataM, extra)

  push!(self.tbM, fill(0, size(self.tbM[1], 1)))

  return tb, self.dataM

end

################################################################################

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
  # mPen = 5000.
  mPen = 200. #  TODO: Added code. change penalty
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

#  TODO: Added code
  # // Bhattacharyya distance
  # double BhattDist(const HMMVec & h) const {
    # double d = 0.;
    # for (int i=0; i<m_data.isize(); i++) {
      # d += sqrt(m_data[i]*h[i]);
    # }
    # d = -log(d+1.);
    # return d;
  # }

  # double Amplitude() const {
    # int i;
    # double d = 0.;
    # for (i=0; i<m_data.isize(); i++) {
      # d += (m_data[i]*m_data[i]);
    # }
    # return sqrt(d);
  # }

"Bhattacharyya distance"
function bhattDist(arr::Array{Float64, 1}, h::Array{Float64, 1})
  dis = 0.
  for ix in eachindex(arr)
    # TODO: this product should be positive
    product = arr[ix] * h[ix]
    if product >= 0
      dis += sqrt(product)
    else
      @error("Product $product is less than zero")
    end
    # dis += sqrt(Complex(arr[ix] - h[ix])).re
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
          sig = jx # - 1 # adjust for 0-index?
        end
      end

      tb[ix] = state
      state = sig

    end

    tb = tb[1:end - 1]

    # @info "Print TB:"
    # for ix in eachindex(tb)
    #   print(ix)
    #   println(": ", tb[ix])
    # end

    return tb
  end
end

################################################################################

function process(self::HMM, d::Array{Float64, 2}, pen::Float64, splitSw::Bool)

  # @info "Reset"
  reset!(self)

    # @info "Feed frame $(ix)"
  for ix in axes(d, 1)
    feed(self, ix, d, pen)
  end

  # @info "Backtrace"
  tb = backTrace(self)

  divider = fill(1, size(self.dataM, 1))
  orig = deepcopy(self.dataM)
  pp = StructArrays.StructArray{ScorePair}(undef, 0)

  # @info "Update model"
  mdist = zeros(Float64, size(self.dataM))
  mcount = zeros(Float64, size(self.dataM))

  # TODO: Added code
  # svec<double> mdist;
  # svec<double> mcount;

  # mdist.resize(m_data.isize(), 0.);
  # mcount.resize(m_data.isize(), 0);

  for ix in axes(d, 1)
    self.dataM[tb[ix]] .+= d[ix, :]
    divider[tb[ix]] += 1
    # pair = ScorePair(bhattDist(orig[tb[ix]], d[ix, :]), ix) # use Bhattacharyya distance
    pair = ScorePair(distance(orig[tb[ix]], d[ix, :]), ix) # use Euclidean distance

    mdist[tb[ix]] += pair.score
    mcount[tb[ix]] += 1

    # TODO: Added code
    # mdist[tb[i]] += pair.score;
    # mcount[tb[i]]++;

    push!(pp, pair)
  end

  scores = sort(pp.score, rev = true)
  ixs = map(x -> findall(x .== pp.score), scores)
  pp = pp[vcat(ixs...)]

  for ix in eachindex(self.dataM)
    self.dataM[ix] /= divider[ix]
  end

  # for jx in eachindex(self.dataM)
  #   @info "Print state $(jx)"
  #   for ix in eachindex(self.dataM[jx])
  #     @info self.dataM[jx][ix]
  #   end
  # end
  #  TODO: Added code

# @info self.dataM

  sortHMM!(self)

  if !splitSw
    return
  end

  # if (!bSplit)
    # return;
  max = 0.
  toSplit = 0
  minFreq = 20

  # double max = 0.;
  # int toSplit = 0;
  # int minFreq = 20; // HARD CODED!!!!

  for ix in eachindex(mdist)
    if mcount[ix] > minFreq
      avdist = mdist[ix] / mcount[ix]
      # @info("Model $ix")
      @info("Model $ix score $avdist count: $(mcount[ix]) raw: $(mdist[ix]) amplitude: $(amplitude(self.dataM[ix]))")
      if avdist > max
        max = d
        toSplit = ix
      end
    end
  end

  # for (i=0; i<mdist.isize(); i++) {
    # if (mcount[i] > minFreq) {
      # double d = mdist[i]/(double)mcount[i];
      # cout << "Model " << i << " score: " << d << " count: " << mcount[i] << " raw: " << mdist[i];
      # cout << " amplitude: " << m_data[i].Amplitude() << endl;
      # if (d > max) {
	# max = d;
	# toSplit = i;
      # }
    # }
  # }

  toSplit = 1
  half = 1 + mcount[toSplit] / 4
  @info("Splitting: $toSplit using $half frames")

  # //toSplit = 0;

  # int half = 1 + mcount[toSplit]/4;

  # cout << "Splitting: " << toSplit << " using " << half << " frames" << endl;

  # //for (i=0; i<pp.isize(); i++)
  # // cout << "DIST " << pp[i].index << " " << pp[i].score << endl;



  extra = fill(0, size(self.dataM[1], 1))

  @info("Split")

  count = 1
  for ix in eachindex(pp)
    @info ix
    if tb[pp[ix].index] != toSplit
      continue
    end
    @info("DIST $(pp[ix].index) $(pp[ix].score) -> $(tb[pp[ix].index])")
    extra += d[pp[ix].index, :]
    count += 1
    if count >= half
      break
    end
  end

  #  TODO: Added code
  # for (i=0; i<pp.isize(); i++) {
    # if (tb[pp[i].index] != toSplit) // Only count frames from toSplit
      # continue;
    # cout << "DIST " << pp[i].index << " " << pp[i].score << " -> " << tb[pp[i].index] << endl;
    # extra += d[pp[i].index];
    # count += 1.;
    # if (count >= half)
      # break;

  # co = 0
  # for ix in 1:floor(Int64, (5 + size(pp, 1) / 50))
  #   extra += d[pp.index[ix], :]
  #   co += 1
  # end

  @info "Extra"
  @info extra

  extra ./= (count - 1)

  @info extra

  push!(self.dataM, extra)

  push!(self.tbM, fill(0, size(self.tbM[1], 1)))

  return tb, self.dataM

end

################################################################################

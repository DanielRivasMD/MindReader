####################################################################################################

"""

    accuracy(ɒ::M)
      where M <: Matrix{N}
      where N <: Number

# Description
Calculate accuracy from contingency table or confusion matrix.

# Examples
```jldoctest
julia> χ = [20 180; 10 1820]
julia> accuracy(χ)
0.9064039408866995
```


See also: [`predictiveValue`](@ref)
"""
function accuracy(ɒ::M) where M <: Matrix{N} where N <: Number
  if size(ɒ) == (2, 2)
    return (ɒ[1, 1] + ɒ[2, 2]) / (sum(ɒ))
  else
    @error "Array does not have the proper size"
  end
end

####################################################################################################

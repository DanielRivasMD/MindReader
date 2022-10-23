####################################################################################################

"""

    PPV(ɒ::M)
      where M <: Matrix{N}
      where N <: Number

# Description
Calculate Positive Predictive Value (PPV) from contingency table or confusion matrix.
Also called Precision.

# Examples
```jldoctest
julia> χ = [20 180; 10 1820]
julia> PPV(χ)
0.1
```


See also: [`predictiveValue`](@ref)
"""
function PPV(ɒ::M) where M <: Matrix{N} where N <: Number
  if size(ɒ) == (2, 2)
    return ɒ[1, 1] / (ɒ[1, 1] + ɒ[1, 2])
  else
    @error "Array does not have the proper size"
  end
end

####################################################################################################

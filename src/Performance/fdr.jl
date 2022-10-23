####################################################################################################

"""

    FDR(ɒ::M)
      where M <: Matrix{N}
      where N <: Number

# Description
Calculate False Discovery Rate (FDR) from contingency table or confusion matrix.

# Examples
```jldoctest
julia> χ = [20 180; 10 1820]
julia> FDR(χ)
0.9
```


See also: [`predictiveValue`](@ref)
"""
function FDR(ɒ::M) where M <: Matrix{N} where N <: Number
  if size(ɒ) == (2, 2)
    return ɒ[1, 2] / (ɒ[1, 1] + ɒ[1, 2])
  else
    @error "Array does not have the proper size"
  end
end

####################################################################################################

####################################################################################################

"""

    MCC(ɒ::M)
      where M <: Matrix{N}
      where N <: Number

# Description
Calculate Mathews Correlation Coeficient (MCC) from contingency table or confusion matrix.
Also called Φ Coeficient.

# Examples
```jldoctest
julia> χ = [6 1; 2 3]
julia> MCC(χ)
0.47809144373375745

julia> χ = [20 180; 10 1820]
julia> MCC(χ)
0.23348550853492078
```


See also: [`predictiveValue`](@ref)
"""
function MCC(ɒ::M) where M <: Matrix{N} where N <: Number
  if size(ɒ) == (2, 2)
    return ((ɒ[1, 1] * ɒ[2, 2]) - (ɒ[1, 2] * ɒ[2, 1])) / (sqrt((ɒ[1, 1] + ɒ[1, 2]) * (ɒ[1, 1] + ɒ[2, 1]) * (ɒ[2, 2] + ɒ[1, 2]) * (ɒ[2, 2] + ɒ[2, 1])))
  else
    @error "Array does not have the proper size"
  end
end

####################################################################################################

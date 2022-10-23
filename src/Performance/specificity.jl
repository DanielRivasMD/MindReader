####################################################################################################

"""

    specificity(ɒ::M)
      where M <: Matrix{N}
      where N <: Number

# Description
Calculate Specificity from contingency table or confusion matrix.
Also called True Negative Rate (TPR), or Selectivity.

# Examples
```jldoctest
julia> χ = [10 40; 5 45]
julia> specificity(χ)
specificity = 0.5294117647058824

julia> χ = [20 33; 10 37]
julia> specificity(χ)
specificity = 0.5285714285714286

julia> χ = [20 180; 10 1820]
julia> specificity(χ)
specificity = 0.91
```


See also: [`predictiveValue`](@ref)
"""
function specificity(ɒ::M) where M <: Matrix{N} where N <: Number
  if size(ɒ) == (2, 2)
    return ɒ[2, 2] / (ɒ[2, 2] + ɒ[1, 2])
  else
    @error "Array does not have the proper size"
  end
end

####################################################################################################


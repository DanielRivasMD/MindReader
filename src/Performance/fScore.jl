####################################################################################################

"""

    fScore(ɒ::M)
      where M <: Matrix{N}
      where N <: Number

# Description
Calculate f1-score from contingency table or confusion matrix.

# Examples
```jldoctest
julia> χ = [20 180; 10 1820]
julia> fScore(χ)
0.1739130434782609
```


See also: [`performance`](@ref), [`accuracy`](@ref), [`balancedAccuracy`](@ref), [`fScore`](@ref), [`sensitivity`](@ref), [`specificity`](@ref), [`PPV`](@ref), [`NPV`](@ref), [`FPR`](@ref), [`FNR`](@ref), [`FDR`](@ref), [`FOR`](@ref), [`MCC`](@ref).
"""
function fScore(ɒ::M) where M <: Matrix{N} where N <: Number
  if size(ɒ) == (2, 2)
    return 2 * ((PPV(ɒ) * sensitivity(ɒ)) / (PPV(ɒ) + sensitivity(ɒ)))
  else
    @error "Array does not have the proper size"
  end
end

####################################################################################################

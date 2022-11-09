####################################################################################################

"""

    balancedAccuracy(ɒ::M)
      where M <: Matrix{N}
      where N <: Number

# Description
Calculate balanced accuracy from contingency table or confusion matrix.

# Examples
```jldoctest
julia> χ = [20 180; 10 1820]
julia> balancedAccuracy(χ)
0.7883333333333333
```


See also: [`performance`](@ref), [`accuracy`](@ref), [`balancedAccuracy`](@ref), [`fScore`](@ref), [`sensitivity`](@ref), [`specificity`](@ref), [`PPV`](@ref), [`NPV`](@ref), [`FPR`](@ref), [`FNR`](@ref), [`FDR`](@ref), [`FOR`](@ref), [`MCC`](@ref).
"""
function balancedAccuracy(ɒ::M) where M <: Matrix{N} where N <: Number
  if size(ɒ) == (2, 2)
    return (sensitivity(ɒ) + specificity(ɒ)) / (2)
  else
    @error "Array does not have the proper size"
  end
end

####################################################################################################

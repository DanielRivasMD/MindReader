####################################################################################################

"""

    sensitivity(ɒ::M)
      where M <: Matrix{N}
      where N <: Number

# Description
Calculate Sensitivity from contingency table or confusion matrix.
Also called True Positive Rate (TPR), or Recall.

# Examples
```jldoctest
julia> χ = [10 40; 5 45]
julia> sensitivity(χ)
sensitivity = 0.6666666666666666

julia> χ = [20 33; 10 37]
julia> sensitivity(χ)
sensitivity = 0.6666666666666666

julia> χ = [20 180; 10 1820]
julia> sensitivity(χ)
sensitivity = 0.6666666666666666
```


See also: [`performance`](@ref), [`accuracy`](@ref), [`balancedAccuracy`](@ref), [`fScore`](@ref), [`sensitivity`](@ref), [`specificity`](@ref), [`PPV`](@ref), [`NPV`](@ref), [`FPR`](@ref), [`FNR`](@ref), [`FDR`](@ref), [`FOR`](@ref), [`MCC`](@ref).
"""
function sensitivity(ɒ::M) where M <: Matrix{N} where N <: Number
  if size(ɒ) == (2, 2)
    return ɒ[1, 1] / (ɒ[1, 1] + ɒ[2, 1])
  else
    @error "Array does not have the proper size"
  end
end

####################################################################################################

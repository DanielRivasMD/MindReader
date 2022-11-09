####################################################################################################

"""

    FNR(ɒ::M)
      where M <: Matrix{N}
      where N <: Number

# Description
Calculate False Negative Rate (FNR) from contingency table or confusion matrix.
Also called Miss Rate.

# Examples
```jldoctest
julia> χ = [20 180; 10 1820]
julia> FNR(χ)
0.3333333333333333
```


See also: [`performance`](@ref), [`accuracy`](@ref), [`balancedAccuracy`](@ref), [`fScore`](@ref), [`sensitivity`](@ref), [`specificity`](@ref), [`PPV`](@ref), [`NPV`](@ref), [`FPR`](@ref), [`FNR`](@ref), [`FDR`](@ref), [`FOR`](@ref), [`MCC`](@ref).
"""
function FNR(ɒ::M) where M <: Matrix{N} where N <: Number
  if size(ɒ) == (2, 2)
    return ɒ[2, 1] / (ɒ[1, 1] + ɒ[2, 1])
  else
    @error "Array does not have the proper size"
  end
end

####################################################################################################

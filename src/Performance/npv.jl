####################################################################################################

"""

    NPV(ɒ::M)
      where M <: Matrix{N}
      where N <: Number

# Description
Calculate Negative Predictive Value (NPV) from contingency table or confusion matrix.

# Examples
```jldoctest
julia> χ = [20 180; 10 1820]
julia> NPV(χ)
0.994535519125683
```


See also: [`performance`](@ref), [`accuracy`](@ref), [`balancedAccuracy`](@ref), [`fScore`](@ref), [`sensitivity`](@ref), [`specificity`](@ref), [`PPV`](@ref), [`NPV`](@ref), [`FPR`](@ref), [`FNR`](@ref), [`FDR`](@ref), [`FOR`](@ref), [`MCC`](@ref).
"""
function NPV(ɒ::M) where M <: Matrix{N} where N <: Number
  if size(ɒ) == (2, 2)
    return ɒ[2, 2] / (ɒ[2, 2] + ɒ[2, 1])
  else
    @error "Array does not have the proper size"
  end
end

####################################################################################################

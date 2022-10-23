####################################################################################################

"""

    FPR(ɒ::M)
      where M <: Matrix{N}
      where N <: Number

# Description
Calculate False Positive Rate (FPR) from contingency table or confusion matrix.
Also called Fall-out.

# Examples
```jldoctest
julia> χ = [20 180; 10 1820]
julia> FPR(χ)
0.09
```


See also: [`performance`](@ref), [`accuracy`](@ref), [`fScore`](@ref), [`sensitivity`](@ref), [`specificity`](@ref), [`PPV`](@ref), [`NPV`](@ref), [`FPR`](@ref), [`FNR`](@ref), [`FDR`](@ref), [`FOR`](@ref), [`MCC`](@ref).
"""
function FPR(ɒ::M) where M <: Matrix{N} where N <: Number
  if size(ɒ) == (2, 2)
    return ɒ[1, 2] / (ɒ[1, 2] + ɒ[2, 2])
  else
    @error "Array does not have the proper size"
  end
end

####################################################################################################

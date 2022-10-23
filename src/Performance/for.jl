####################################################################################################

"""

    FOR(ɒ::M)
      where M <: Matrix{N}
      where N <: Number

# Description
Calculate False Omission Rate (FOR) from contingency table or confusion matrix.

# Examples
```jldoctest
julia> χ = [20 180; 10 1820]
julia> FOR(χ)
0.00546448087431694
```


See also: [`performance`](@ref),[`accuracy`](@ref),[`fScore`](@ref),[`sensitivity`](@ref),[`specificity`](@ref),[`PPV`](@ref),[`NPV`](@ref),[`FPR`](@ref),[`FNR`](@ref),[`FDR`](@ref),[`FOR`](@ref),[`MCC`](@ref)
"""
function FOR(ɒ::M) where M <: Matrix{N} where N <: Number
  if size(ɒ) == (2, 2)
    return ɒ[2, 1] / (ɒ[2, 1] + ɒ[2, 2])
  else
    @error "Array does not have the proper size"
  end
end

####################################################################################################

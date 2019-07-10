struct Fill{T} <: Imputor
    value::T
    vardim::Int
    context::AbstractContext
end

"""
    Fill(; value=mean, vardim=2, context=Context())

Fills in the missing data with a specific value.
The current implementation is univariate, so each variable in a table or matrix will
be handled independently.

# Keyword Arguments
* `value::Any`: A scalar missing value or a function that returns the a scalar if
  passed the data with missing data removed (e.g, `mean`)
* `vardim=2::Int`: Specify the dimension for variables in matrix input data
* `context::AbstractContext`: A context which keeps track of missing data
  summary information

# Example
```jldoctest
julia> using Impute: Fill, Context, impute

julia> M = [1.0 2.0 missing missing 5.0; 1.1 2.2 3.3 missing 5.5]
2×5 Array{Union{Missing, Float64},2}:
 1.0  2.0   missing  missing  5.0
 1.1  2.2  3.3       missing  5.5

julia> impute(Fill(; vardim=1, context=Context(; limit=1.0)), M)
2×5 Array{Union{Missing, Float64},2}:
 1.0  2.0  2.66667  2.66667  5.0
 1.1  2.2  3.3      3.025    5.5
```
"""
Fill(; value=mean, vardim=2, context=Context()) = Fill(value, vardim, context)

function impute!(imp::Fill, data::AbstractVector)
    imp.context() do c
        fill_val = if isa(imp.value, Function)
            # Call `deepcopy` because we can trust that it's available for all types.
            imp.value(Impute.drop(deepcopy(data); context=c))
        else
            imp.value
        end

        for i in 1:length(data)
            if ismissing(c, data[i])
                data[i] = fill_val
            end
        end

        return data
    end
end

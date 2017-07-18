replace_placeholder(x) = x

function replace_placeholder(expr::Expr)
    if expr.head == :call
        for i = 2:length(expr.args)
            arg = expr.args[i]
            if arg isa Expr && arg.head == :(::)
                if arg.args[1] == :IO
                    # show(::IO, ...)
                    placeholder = arg.args[1]
                    nvar = Symbol("#io")
                    nexpr = deepcopy(expr)
                    nexpr.args[i] = nvar
                    nexpr = quote
                        $nvar = IOBuffer()
                        $nexpr
                        readstring(seek($nvar, 0))
                    end
                    return nexpr
                end
            end
        end
    end
    return expr
end

macro test_reference(reference, actual, kws...)
    new_actual = replace_placeholder(actual)
    expr = :(test_reference_file(abspath(joinpath(@__DIR__, $(esc(reference)))), $(esc(new_actual))))
    for kw in kws
        (kw isa Expr && kw.head == :(=)) || error("invalid signature for @test_reference")
        push!(expr.args, Expr(:kw, kw.args...))
    end
    expr
end

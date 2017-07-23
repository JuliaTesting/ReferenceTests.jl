macro test_reference(reference, actual, kws...)
    expr = :(test_reference_file(abspath(joinpath(@__DIR__, $(esc(reference)))), $(esc(actual))))
    for kw in kws
        (kw isa Expr && kw.head == :(=)) || error("invalid signature for @test_reference")
        push!(expr.args, Expr(:kw, kw.args...))
    end
    expr
end

# --------------------------------------------------------------------

io2str_impl(x) = x

function io2str_impl(expr::Expr)
    nvar = Symbol("#io#", randstring(4))
    if replace_expr!(expr, :(::IO), nvar)
        esc(quote
            $nvar = Base.IOBuffer()
            $expr
            Base.readstring(Base.seek($nvar, 0))
        end)
    else
        expr
    end
end

macro io2str(expr)
    io2str_impl(expr)
end

# --------------------------------------------------------------------

function withcolor(fun)
    old_color = Base.have_color
    try
        eval(Base, :(have_color = true))
        fun()
    finally
        eval(Base, :(have_color = $old_color))
    end
end

macro withcolor(expr)
    :(withcolor(()->$(esc(expr))))
end

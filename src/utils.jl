"""
    @io2str ex

TODO
"""
macro io2str(expr)
    io2str_impl(expr)
end

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

function replace_expr!(expr, old, new)
    expr == old && throw(ArgumentError("can't replace root expression"))
    found = false
    if expr isa Expr
        for i = 1:length(expr.args)
            arg = expr.args[i]
            if arg == old
                expr.args[i] = new
                found = true
            else
                found = found || replace_expr!(arg, old, new)
            end
        end
    end
    found
end

# --------------------------------------------------------------------

"""
    @withcolor ex

Makes sure that `ex` is evaluated while `Base.have_color` is set
to `true`. The original value of `Base.have_color` will be
restored afterwards.

This macro is particularily useful for CI, where `julia` is
executed without the `--color=yes` argument by default.
"""
macro withcolor(expr)
    :(withcolor(()->$(esc(expr))))
end

function withcolor(fun)
    old_color = Base.have_color
    try
        eval(Base, :(have_color = true))
        fun()
    finally
        eval(Base, :(have_color = $old_color))
    end
end

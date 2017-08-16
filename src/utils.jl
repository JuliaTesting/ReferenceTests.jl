function query_extended(filename)
    file, ext = splitext(filename)
    # TODO: make this less ugly
    if uppercase(ext) == ".TXT"
        File{format"TXT"}(filename)
    elseif uppercase(ext) == ".SHA1"
        File{format"SHA1"}(filename)
    else
        query(filename)
    end
end

# --------------------------------------------------------------------

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

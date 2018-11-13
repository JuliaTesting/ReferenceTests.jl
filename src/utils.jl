"""
    @io2str ex

Search and replace the placeholder `::IO` with a newly allocated
`Base.IOBuffer` which is afterwards converted to a string and
returned.

This macro allows a user to conveniently test text-based printing
functionality that require an `IO` argument. A particularly
common example of such would be a custom `Base.show` method.

# Examples

```jldoctest
julia> using ReferenceTests

julia> @io2str print(::IO, "Hello World")
"Hello World"

julia> @io2str show(IOContext(::IO, :limit=>true, :displaysize=>(10,10)), "text/plain", ones(10))
"10-element Array{Float64,1}:\\n 1.0\\n 1.0\\n 1.0\\n ⋮  \\n 1.0\\n 1.0"
```
"""
macro io2str(expr)
    io2str_impl(expr)
end

io2str_impl(arg) = :(throw(ArgumentError("Invalid use of `@io2str` macro: The given argument `$($(string(arg)))` is not an expression.")))

function io2str_impl(expr::Expr)
    nvar = gensym("io")
    if replace_expr!(expr, :(::IO), nvar)
        esc(quote
            $nvar = Base.IOBuffer()
            $expr
            Base.String(Base.resize!($nvar.data, $nvar.size))
        end)
    else
        :(throw(ArgumentError("Invalid use of `@io2str` macro: The given expression `$($(string(expr)))` does not contain `::IO` placeholder in a supported manner")))
    end
end

function replace_expr!(expr, pat, r)
    expr == pat && throw(ArgumentError("can't replace root expression"))
    found = false
    if expr isa Expr
        for i = 1:length(expr.args)
            arg = expr.args[i]
            if arg == pat
                expr.args[i] = r
                found = true
            else
                found = found || replace_expr!(arg, pat, r)
            end
        end
    end
    found
end

# --------------------------------------------------------------------

"""
    @withcolor ex

Make sure that `ex` is evaluated while `Base.have_color` is set
to `true`. The original value of `Base.have_color` will be
restored afterwards.

This macro is particularily useful for CI, where it is not
unusual that  `julia` is executed without the `--color=yes`
argument by default.

```julia
@withcolor print_with_color(:green, "foo")
```
"""
macro withcolor(expr)
    :(withcolor(()->$(esc(expr))))
end

function withcolor(fun)
    old_color = Base.have_color
    try
        Core.eval(Base, :(have_color = true))
        fun()
    finally
        Core.eval(Base, :(have_color = $old_color))
    end
end

# --------------------------------------------------------------------

function input_bool(prompt)
    while true
        println(prompt, " [y/n]")
        response = readline()
        length(response) == 0 && continue
        reply = lowercase(first(strip(response)))
        if reply == 'y'
            return true
        elseif reply =='n'
            return false
        end
        # Otherwise loop and repeat the prompt
    end
end


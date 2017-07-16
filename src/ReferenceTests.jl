module ReferenceTests

using FileIO

export

    @test_reference

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

macro test_reference(filename, expr)
    nexpr = replace_placeholder(expr)
    :(test_reference_impl($filename, $(esc(nexpr))))
end

function extended_query(filename)
    file, ext = splitext(filename)
    if ext == "" || uppercase(ext) == ".txt"
        File{format"TXT"}(filename)
    else
        query(filename)
    end
end

function test_reference_impl(filename, actual)
    println(filename, " ", actual)
end

end # module

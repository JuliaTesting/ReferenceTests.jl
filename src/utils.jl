function extended_query(filename)
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

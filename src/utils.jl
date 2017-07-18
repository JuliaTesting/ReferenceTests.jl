function extended_query(filename)
    file, ext = splitext(filename)
    if uppercase(ext) == ".TXT"
        File{format"TXT"}(filename)
    elseif uppercase(ext) == ".SHA1"
        File{format"SHA1"}(filename)
    else
        query(filename)
    end
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

macro withcolor(expr)
    :(withcolor(()->$(esc(expr))))
end

function extended_query(filename)
    file, ext = splitext(filename)
    if uppercase(ext) == ".TXT"
        File{format"TXT"}(filename)
    else
        query(filename)
    end
end

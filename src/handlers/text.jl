# --------------------------------------------------------------------
# plain TXT

function test_reference(file::File{format"TXT"}, actual; render = Diff())
    _test_reference(render, file, string(actual))
end

function test_reference(file::File{format"TXT"}, actual::AbstractArray{<:AbstractString}; render = Diff())
    str = join(actual, '\n')
    _test_reference(render, file, str)
end

# --------------------------------------------------------------------
# SHA as string

function test_reference(file::File{format"SHA256"}, actual)
    test_reference(file, string(actual))
end

function test_reference(file::File{format"SHA256"}, actual::Union{AbstractString,Vector{UInt8}})
    str = bytes2hex(sha256(actual))
    _test_reference(BeforeAfterFull(), file, str)
end

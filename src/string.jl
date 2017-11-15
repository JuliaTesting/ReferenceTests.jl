# --------------------------------------------------------------------
# plain TXT

function test_reference(file::File{format"TXT"}, actual)
    test_reference_string(file, string(actual))
end

function test_reference(file::File{format"TXT"}, actual::AbstractArray{<:AbstractString})
    test_reference_string(file, actual)
end

# Image as txt using ImageInTerminal
function test_reference(file::File{format"TXT"}, actual::AbstractArray{<:Colorant}; size = (20,40))
    str = @withcolor ImageInTerminal.encodeimg(ImageInTerminal.SmallBlocks(), ImageInTerminal.TermColor256(), actual, size...)[1]
    test_reference_string(file, str)
end

# --------------------------------------------------------------------
# SHA as string

function test_reference(file::File{format"SHA256"}, actual)
    test_reference(file, string(actual))
end

function test_reference(file::File{format"SHA256"}, actual::Union{AbstractString,Vector{UInt8}})
    str = bytes2hex(sha256(actual))
    test_reference_string(file, str)
end

function test_reference(file::File{format"SHA256"}, actual::AbstractArray{<:Colorant})
    size_str = bytes2hex(sha256(reinterpret(UInt8,[map(Int64,size(actual))...])))
    img_str = bytes2hex(sha256(reinterpret(UInt8,vec(rawview(channelview(actual))))))
    test_reference_string(file, size_str * img_str)
end

# --------------------------------------------------------------------

function test_reference_string(file::File, actual::AbstractString)
    path = file.filename
    dir, filename = splitdir(path)
    try
        reference = readstring(path)
        @test reference == actual # This is not really what should be used but... for now
    catch ex
        if ex isa SystemError # File doesn't exist
            inner =  Fail(:test, :(@test_reference "$path" (missing)  == actualcodehere),
                                                # ^This is a lie as to the original expression, it is almost good enough except should use original code for actual
                                                Expr(:comparison, "", :(==), actual), # This makes simple diffs work
                                                @__LINE__) #WRONG: Should be the line of the test that failed
            res = MissingFile(path, actual, inner)
            record(get_testset(), res)
        else
            throw(ex)
        end
    end
end

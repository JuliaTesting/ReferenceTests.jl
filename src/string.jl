# --------------------------------------------------------------------
# plain TXT

function test_reference(file::File{format"TXT"}, actual)
    test_reference_string(file, string(actual))
end

function test_reference(file::File{format"TXT"}, actual::AbstractVector)
    str = join(actual,"\n")
    test_reference_string(file, str)
end

# Image as txt using ImageInTerminal
function test_reference(file::File{format"TXT"}, actual::AbstractArray{<:Colorant}; size = (20,40))
    data = @withcolor ImageInTerminal.encodeimg(ImageInTerminal.SmallBlocks(), ImageInTerminal.TermColor256(), actual, size...)[1]
    test_reference(file, data)
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
# Core functionality

function test_reference_string(file::File, actual::AbstractString)
    path = file.filename
    dir, filename = splitdir(path)
    try
        reference = readstring(path)
        if reference != actual
            process_result(MismatchedFile(path, reference, actual))
        else
            @test true # they are equal so make it pass
        end
    catch ex
        if ex isa SystemError # File doesn't exist
            process_result(MissingFile(path, actual))
        else
            rethrow(ex)
        end
    end
end

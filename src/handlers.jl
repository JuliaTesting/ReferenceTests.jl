# --------------------------------------------------------------------
# plain TXT

function test_reference(file::File{format"TXT"}, actual; by = isequal, render = Diff())
    _test_reference(by, render, file, string(actual))
end

function test_reference(file::File{format"TXT"}, actual::Number; by = isequal, render = BeforeAfterFull())
    _test_reference(by, render, file, actual)
end

function test_reference(file::File{format"TXT"}, actual::AbstractArray{<:AbstractString}; by = isequal, render = Diff())
    str = join(actual, '\n')
    _test_reference(by, render, file, str)
end

# ---------------------------------
# Image

function test_reference(file::File, actual::AbstractArray{<:Colorant}; by = default_image_equality, render = BeforeAfterImage())
    _test_reference(by, render, file, actual)
end

# Image as txt using ImageInTerminal
function test_reference(file::File{format"TXT"}, actual::AbstractArray{<:Colorant}; size = (20,40), by = isequal, render = BeforeAfterFull())
    strs = @withcolor ImageInTerminal.encodeimg(ImageInTerminal.SmallBlocks(), ImageInTerminal.TermColor256(), actual, size...)[1]
    str = join(strs,'\n')
    _test_reference(by, render, file, str)
end

# --------------------------------------------------------------------
# SHA as string

function test_reference(file::File{format"SHA256"}, actual; by = nothing, render = BeforeAfterFull())
    test_reference(file, string(actual); render = render)
end

function test_reference(file::File{format"SHA256"}, actual::Union{AbstractString,Vector{UInt8}}; by = nothing, render = BeforeAfterFull())
    str = bytes2hex(sha256(actual))
    _test_reference(isequal, render, file, str)
end

function test_reference(file::File{format"SHA256"}, actual::AbstractArray{<:Colorant}; by = nothing, render = BeforeAfterFull())
    size_str = bytes2hex(sha256(reinterpret(UInt8,[map(Int64,size(actual))...])))
    img_str = bytes2hex(sha256(reinterpret(UInt8,vec(rawview(channelview(actual))))))
    _test_reference(isequal, render, file, size_str * img_str)
end

# --------------------------------------------------------------------

# Fallback
function test_reference(file::File, actual; by = isequal, render = nothing)
    if !(render === nothing)
        _test_reference(by, render, file, actual)
    else
        if actual isa AbstractString
            # we don't use dispatch for this as it is very ambiguous
            # specialization will remove this conditional regardless

            _test_reference(by, Diff(), file, actual)
        else
            _test_reference(by, BeforeAfterLimited(), file, actual)
        end
    end
end

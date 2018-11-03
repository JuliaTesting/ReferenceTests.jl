# --------------------------------------------------------------------
# plain TXT

function test_reference(file::File{format"TXT"}, actual; render = Diff())
    _test_reference(render, file, string(actual))
end

function test_reference(file::File{format"TXT"}, actual::AbstractArray{<:AbstractString}; render = Diff())
    str = join(actual, '\n')
    _test_reference(render, file, str)
end

# ---------------------------------
# Image

function test_reference(file::File, actual::AbstractArray{<:Colorant}; sigma=ones(length(axes(actual))), eps=0.01)
    _test_reference(BeforeAfterImage(), file, actual) do reference, actual
        try
            Images.@test_approx_eq_sigma_eps(reference, actual, sigma, eps)
            return true
        catch err
            if err isa ErrorException
                return false
            else
                rethrow()
            end
        end
    end
end

# Image as txt using ImageInTerminal
function test_reference(file::File{format"TXT"}, actual::AbstractArray{<:Colorant}; size = (20,40), render = BeforeAfterFull())
    strs = @withcolor ImageInTerminal.encodeimg(ImageInTerminal.SmallBlocks(), ImageInTerminal.TermColor256(), actual, size...)[1]
    str = join(strs,'\n')
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

function test_reference(file::File{format"SHA256"}, actual::AbstractArray{<:Colorant})
    size_str = bytes2hex(sha256(reinterpret(UInt8,[map(Int64,size(actual))...])))
    img_str = bytes2hex(sha256(reinterpret(UInt8,vec(rawview(channelview(actual))))))
    _test_reference(BeforeAfterFull(), file, size_str * img_str)
end

# --------------------------------------------------------------------

# Fallback
function test_reference(file::File, actual)
    if actual isa AbstractString
        # we don't use dispatch for this as it is very ambiguous
        # specialization will remove this conditional regardless

        _test_reference(Diff(), file, actual)
    else
        _test_reference(BeforeAfterLimited(), file, actual)
    end
end

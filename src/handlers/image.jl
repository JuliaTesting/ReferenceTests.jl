using Images
using ColorTypes
using ImageCore
using ImageInTerminal

# ---------------------------------
# Image
# @require Images # TODO: Images is a large dependency

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

# ---------------------------------
# Image as txt using ImageInTerminal
# @require ImageInTerminal

function test_reference(file::File{format"TXT"}, actual::AbstractArray{<:Colorant}; size = (20,40), render = BeforeAfterFull())
    strs = @withcolor ImageInTerminal.encodeimg(ImageInTerminal.SmallBlocks(), ImageInTerminal.TermColor256(), actual, size...)[1]
    str = join(strs,'\n')
    _test_reference(render, file, str)
end

function test_reference(file::File{format"SHA256"}, actual::AbstractArray{<:Colorant})
    size_str = bytes2hex(sha256(reinterpret(UInt8,[map(Int64,size(actual))...])))
    img_str = bytes2hex(sha256(reinterpret(UInt8,vec(rawview(channelview(actual))))))
    _test_reference(BeforeAfterFull(), file, size_str * img_str)
end

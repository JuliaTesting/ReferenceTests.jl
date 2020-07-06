#######################################
# IO
# Right now this basically just extends FileIO to support some things as text files

const TextFile = Union{File{format"TXT"}, File{format"SHA256"}}

function loadfile(T, file::File)
    T(load(file)) # Fallback to FileIO
end

function loadfile(T, file::TextFile)
    _ignore_crlf(read(file.filename, String))
end

function loadfile(::Type{<:Number}, file::File{format"TXT"})
    parse(Float64, loadfile(String, file))
end

function savefile(file::File, content)
    save(file, content) # Fallback to FileIO
end

function savefile(file::TextFile, content)
    write(file.filename, string(content))
end

function query_extended(filename::AbstractString)
    file, ext = splitext(filename)
    # TODO: make this less hacky
    if uppercase(ext) == ".SHA256"
        res = File{format"SHA256"}(filename)
    else
        res = query(filename)
        if res isa File{DataFormat{:UNKNOWN}}
            res = File{format"TXT"}(filename)
        end
    end
    res
end

# Some target formats are not supported by FileIO and thus require an encoding/compression process
# before saving. For other formats, we should trust IO backends and make as few changes as possible.
# Otherwise, reference becomes unfaithful. The encoding process helps making the actual data matches
# the reference data, which is load from reference file via IO backends.
#
# TODO: split `maybe_encode` to `maybe_preprocess` and `maybe_encode`
"""
    maybe_encode(T::Type{<:DataFormat}, x; kw...) -> out

If needed, encode `x` to a valid content that matches format `T`.

If there is no known method to encode `x`, then it directly return `x` without warning.
"""
maybe_encode(::Type{<:DataFormat}, x; kw...) = x

# plain TXT
maybe_encode(::Type{DataFormat{:TXT}}, x; kw...) = _ignore_crlf(string(x))
maybe_encode(::Type{DataFormat{:TXT}}, x::AbstractArray{<:AbstractString}; kw...) = _join(x)
maybe_encode(::Type{DataFormat{:TXT}}, x::AbstractString; kw...) = _ignore_crlf(x)
maybe_encode(::Type{DataFormat{:TXT}}, x::Number; kw...) = x # TODO: Change this to string(x) ?

function maybe_encode(
    ::Type{DataFormat{:TXT}}, img::AbstractArray{<:Colorant};
    size = (20,40), kw...)

    # encode image into string
    strs = @withcolor ImageInTerminal.encodeimg(
        ImageInTerminal.SmallBlocks(),
        ImageInTerminal.TermColor256(),
        img,
        size...)[1]
    return join(strs,'\n')
end

# SHA256
maybe_encode(::Type{DataFormat{:SHA256}}, x; kw...) = _sha256(string(x))
maybe_encode(::Type{DataFormat{:SHA256}}, x::AbstractString) = _sha256(_ignore_crlf(x))
maybe_encode(::Type{DataFormat{:SHA256}}, x::AbstractArray{<:AbstractString}) = _sha256(_join(x))
function maybe_encode(::Type{DataFormat{:SHA256}}, img::AbstractArray{<:Colorant}; kw...)
    # encode image into SHA256
    size_str = _sha256(reinterpret(UInt8,[map(Int64,size(img))...]))
    img_str = _sha256(reinterpret(UInt8,vec(rawview(channelview(img)))))

    return size_str * img_str
end


# Helpers
_join(x::AbstractArray{<:AbstractString}) = mapreduce(_ignore_crlf, (x,y)->x*"\n"*y, x)
_sha256(x) = bytes2hex(sha256(x))
_ignore_crlf(x::AbstractString) = replace(x, "\r"=>"")

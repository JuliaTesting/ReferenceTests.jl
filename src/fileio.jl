#######################################
# IO
# Right now this basically just extends FileIO to support some things as text files

const TextFile = Union{File{format"TXT"}, File{format"SHA256"}}

function loadfile(T, file::File)
    T(load(file)) # Fallback to FileIO
end

function loadfile(T, file::TextFile)
    replace(read(file.filename, String), "\r"=>"")
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

function query_extended(filename)
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

"""
    _convert(T::Type{<:DataFormat}, x; kw...) -> out

Convert `x` to a validate content for file data format `T`.
"""
_convert(::Type{<:DataFormat}, x; kw...) = x

# plain TXT
_convert(::Type{DataFormat{:TXT}}, x; kw...) = string(x)
_convert(::Type{DataFormat{:TXT}}, x::Number; kw...) = x
function _convert(::Type{DataFormat{:TXT}}, x::AbstractArray{<:AbstractString}; kw...)
    return join(x, '\n')
end
function _convert(
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
_convert(::Type{DataFormat{:SHA256}}, x; kw...) = bytes2hex(sha256(string(x)))
function _convert(::Type{DataFormat{:SHA256}}, img::AbstractArray{<:Colorant}; kw...)
    # encode image into SHA256
    size_str = bytes2hex(sha256(reinterpret(UInt8,[map(Int64,size(img))...])))
    img_str = bytes2hex(sha256(reinterpret(UInt8,vec(rawview(channelview(img))))))

    return size_str * img_str
end

#################################################
# Rendering
# This controls how failures are displayed
abstract type RenderMode end
struct Diff <: RenderMode end

abstract type BeforeAfter <: RenderMode end
struct BeforeAfterLimited <: BeforeAfter end
struct BeforeAfterFull <: BeforeAfter end
struct BeforeAfterImage <: BeforeAfter end

color_buffer(args...) =
    IOContext(PipeBuffer(), :color=>Base.get_have_color(), args...)

function render_item(::RenderMode, item)
    io = color_buffer()
    print(io, item)
    read(io, String)
end
function render_item(::BeforeAfterLimited, item)
    io = color_buffer(
        :limit=>true,
        :displaysize=>(20,80)
    )
    show(io, "text/plain", item)
    read(io, String)
end

should_use_sixel() = Sixel.is_sixel_supported() || Base.get_bool_env("REFERENCETESTS_FORCE_SIXEL", false)

function render_item(::BeforeAfterImage, item)
    io = if should_use_sixel()
        PipeBuffer()
    else
        color_buffer()
    end
    println(io, "eltype: ", eltype(item))
    println(io, "size: ", map(length, axes(item)))
    println(io, "thumbnail:")
    if should_use_sixel()
        sixel_encode(io, item)
    else
        strs = @withcolor XTermColors.ascii_show(
            item,
            Base.invokelatest(XTermColors.TermColor8bit),
            :small,
            (20, 40)
        )
        print(io, join(strs, '\n'))
    end
    read(io, String)
end

## 2 arg form render for comparing
render(mode::BeforeAfter, reference, actual) = """
    - REFERENCE -------------------
    $(render_item(mode, reference))
    -------------------------------
    - ACTUAL ----------------------
    $(render_item(mode, actual))
    -------------------------------"""

render(mode::Diff, reference, actual) = """
    - DIFF ------------------------
    $(@withcolor(render_item(mode, deepdiff(reference, actual))))
    -------------------------------"""

## 1 arg form render for new content
render(mode::RenderMode, actual) = """
    - NEW CONTENT -----------------
    $(render_item(mode, actual))
    -------------------------------"""

"""
    default_rendermode(::DataFormat, actual)

Infer the most appropriate render mode according to type of reference file and `actual`.
"""
default_rendermode(::Type{<:DataFormat}, ::Any) = BeforeAfterLimited()
default_rendermode(::Type{<:DataFormat}, ::AbstractString) = Diff()
default_rendermode(::Type{<:DataFormat}, ::AbstractArray{<:Colorant}) = BeforeAfterImage()

# plain TXTs
default_rendermode(::Type{DataFormat{:TXT}}, ::Any) = Diff()
default_rendermode(::Type{DataFormat{:TXT}}, ::AbstractString) = Diff()
default_rendermode(::Type{DataFormat{:TXT}}, ::Number) = BeforeAfterFull()
default_rendermode(::Type{DataFormat{:TXT}}, ::AbstractArray{<:Colorant}) = BeforeAfterImage()

# SHA256
default_rendermode(::Type{DataFormat{:SHA256}}, ::Any) = BeforeAfterFull()
default_rendermode(::Type{DataFormat{:SHA256}}, ::AbstractString) = BeforeAfterFull()
default_rendermode(::Type{DataFormat{:SHA256}}, ::AbstractArray{<:Colorant}) = BeforeAfterLimited()

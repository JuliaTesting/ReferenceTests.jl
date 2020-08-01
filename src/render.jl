#################################################
# Rendering
# This controls how failures are displayed
abstract type RenderMode end
struct Diff <: RenderMode end

abstract type BeforeAfter <: RenderMode end
struct BeforeAfterLimited <: BeforeAfter end
struct BeforeAfterFull <: BeforeAfter end
struct BeforeAfterImage <: BeforeAfter end

render_item(mode::RenderMode, item) = render_item(stdout, mode, item)
render_item(io::IO, ::RenderMode, item) = println(io, item)
function render_item(io::IO, ::BeforeAfterLimited, item)
    show(IOContext(io, :limit=>true, :displaysize=>(20,80)), "text/plain", item)
    println(io)
end
function render_item(io::IO, ::BeforeAfterImage, item::AbstractMatrix)
    # FIXME: encodeimg only support 2d cases right now
    str_item = @withcolor ImageInTerminal.encodeimg(ImageInTerminal.SmallBlocks(), ImageInTerminal.TermColor256(), item, 20, 40)[1]
    println(io, "eltype: ", eltype(item))
    println(io, "size: ", map(length, axes(item)))
    println(io, "thumbnail:")
    foreach(x->println(io, x), str_item)
end

## 2 arg form render for comparing
render(mode::RenderMode, args...) = render(stdout, mode, args...)
function render(io::IO, mode::BeforeAfter, reference, actual)
    println(io, "- REFERENCE -------------------")
    render_item(io, mode, reference)
    println(io, "-------------------------------")
    println(io, "- ACTUAL ----------------------")
    render_item(io, mode, actual)
    println(io, "-------------------------------")
end
function render(io::IO, ::Diff, reference, actual)
    println(io, "- DIFF ------------------------")
    @withcolor println(io, deepdiff(reference, actual))
    println(io, "-------------------------------")
end

## 1 arg form render for new content
function render(io::IO, mode::RenderMode, actual)
    println(io, "- NEW CONTENT -----------------")
    render_item(io, mode, actual)
    println(io, "-------------------------------")
end

# We set the fallback as limited mode because it is not safe/efficient to fully render anything unless
#   * we have prior information that it is not long -- numbers
#   * or, we know how to fully render it efficiently without sending too much noise to IO
#      - Diff mode for strings
#      - BeforeAfterImage for images
# Arrays, in general, should be rendered using limited mode.
"""
    default_rendermode(actual)

Infer the most appropriate render mode according to type of `actual`.
"""
default_rendermode(::Type) = BeforeAfterLimited()
default_rendermode(::Type{T}) where T<:Number = BeforeAfterFull()
default_rendermode(::Type{T}) where T<:AbstractString = Diff()
default_rendermode(::Type{T}) where T<:AbstractArray{<:AbstractString} = Diff()
default_rendermode(::Type{T}) where T<:AbstractArray{<:Colorant} = BeforeAfterImage()

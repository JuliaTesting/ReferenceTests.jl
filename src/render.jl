#################################################
# Rendering
# This controls how failures are displayed
abstract type RenderMode end
struct Diff <: RenderMode end

abstract type BeforeAfter <: RenderMode end
struct BeforeAfterLimited <: BeforeAfter end
struct BeforeAfterFull <: BeforeAfter end
struct BeforeAfterImage <: BeforeAfter end

render_item(::RenderMode, item) = println(item)
function render_item(::BeforeAfterLimited, item)
    show(IOContext(stdout, :limit=>true, :displaysize=>(20,80)), "text/plain", item)
    println()
end
function render_item(::BeforeAfterImage, item)
    str_item = @withcolor ImageInTerminal.ascii_show(
        item,
        ImageInTerminal.TermColor8bit(),
        :small,
        (20, 40)
    )
    println("eltype: ", eltype(item))
    println("size: ", map(length, axes(item)))
    println("thumbnail:")
    println.(str_item)
end

## 2 arg form render for comparing
function render(mode::BeforeAfter, reference, actual)
    println("- REFERENCE -------------------")
    render_item(mode, reference)
    println("-------------------------------")
    println("- ACTUAL ----------------------")
    render_item(mode, actual)
    println("-------------------------------")
end
function render(::Diff, reference, actual)
    println("- DIFF ------------------------")
    @withcolor println(deepdiff(reference, actual))
    println("-------------------------------")
end

## 1 arg form render for new content
function render(mode::RenderMode, actual)
    println("- NEW CONTENT -----------------")
    render_item(mode, actual)
    println("-------------------------------")
end

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

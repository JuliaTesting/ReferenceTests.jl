module ReferenceTests

using Base.Test
using Images
using FileIO
using ImageInTerminal
using ColorTypes
using SHA

export

    @withcolor,
    @io2str,
    @test_reference

include("utils.jl")
include("test_reference.jl")
include("string.jl")

end # module

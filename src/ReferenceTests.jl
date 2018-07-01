module ReferenceTests

using Base.Test
using Requires
using FileIO
using ImageCore
using ImageInTerminal
using ColorTypes
using SHA
using DeepDiffs

export

    @withcolor,
    @io2str,
    @test_reference

include("utils.jl")
include("test_reference.jl")
include("core.jl")
include("handlers.jl")

end # module

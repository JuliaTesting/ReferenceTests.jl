module ReferenceTests

using Base.Test
using FileIO
using ImageInTerminal
using ColorTypes
using SHA

export

    @withcolor,
    @test_reference

include("utils.jl")
include("macros.jl")
include("file.jl")

end # module

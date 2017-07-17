module ReferenceTests

using FileIO
using ImageInTerminal
using ColorTypes

export

    @test_reference

include("utils.jl")
include("macros.jl")
include("file.jl")

end # module

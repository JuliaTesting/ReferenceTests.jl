using Test
using ImageInTerminal, TestImages, ImageCore, ImageTransformations
using DataFrames, CSVFiles
using Random

if isinteractive()
    @info ("In interactive use, one should respond \"n\" when the program"
           * " offers to create or replace files associated with some tests.")
else
    @info ("Ten tests should correctly report failure in the transcript"
           * " (but not the test summary).")
end

# check for ambiguities
refambs = detect_ambiguities(ImageInTerminal, Base, Core)

using ReferenceTests
ambs = detect_ambiguities(ReferenceTests, ImageInTerminal, Base, Core)

const refroot = joinpath(@__DIR__(), "references")

test_files = [
    "equality_metrics.jl",
    "fileio.jl",
    "utils.jl",
    "render.jl",
    "test_reference.jl",
]

include("testutils.jl")

@testset "ReferenceTests" begin
    @test Set(setdiff(ambs, refambs)) == Set{Tuple{Method,Method}}()

    for file in test_files
        filename = first(splitext(file))
        @testset "File: $filename" begin
            include(file)
        end
    end
end  # top level testset

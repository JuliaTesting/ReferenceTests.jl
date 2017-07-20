using ImageInTerminal, Base.Test, ColorTypes

# check for ambiguities
refambs = detect_ambiguities(ImageInTerminal, Base, Core)
using ReferenceTests
ambs = detect_ambiguities(ReferenceTests, ImageInTerminal, Base, Core)
@test length(setdiff(ambs, refambs)) == 0

@testset "io2str" begin
    @test_throws ArgumentError eval(@macroexpand @io2str(::IO))
    @test @io2str(2) == 2
    @test @io2str(string(2)) == "2"
    @test @io2str(print(::IO, "foo")) == "foo"
    @test @io2str(println(::IO, "foo")) == "foo\n"
    @test @io2str(show(::IO, "foo")) == "\"foo\""
    @test @io2str(show(IOContext(::IO, limit=true, displaysize=(5,5)), ones(30,30))) == "[1.0 1.0 … 1.0 1.0; 1.0 1.0 … 1.0 1.0; … ; 1.0 1.0 … 1.0 1.0; 1.0 1.0 … 1.0 1.0]"
end

foo = "foo"
@test_reference "references/string1.txt" join(foo, "bar")
@test_reference "references/img1.txt" rand(RGB, 10, 10)

# @test_reference "img1.png" rand(RGB, 10, 10)
# @test_reference "img1.txt" rand(RGB, 10, 10)

# @test_reference "rand" rand(10, 10)
# @test_reference "rand.csv" rand(10, 10)
# @test_reference "rand.csv" DataTable(v1=[1,2,3], v2=["a","b","c"])

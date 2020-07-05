refdir = joinpath(refroot, "string")

@testset "string as unknown file type" begin
    @test_reference joinpath(refdir, "string1.nottxt") "This is not a .txt file, but it should be treated as such.\n"
end

@testset "string as txt" begin
    foo = "foo"
    @test_reference joinpath(refdir, "string1.txt") foo * "bar"
    @test_reference joinpath(refdir, "string1.txt") [foo * "bar"]
    A = ones(30,30)
    @test_reference joinpath(refdir, "string2.txt") @io2str show(IOContext(::IO, :limit=>true, :displaysize=>(5,5)), A)
    @test_reference joinpath(refdir, "string3.txt") 1337
    @test_reference joinpath(refdir, "string3.txt") 1338 by=(ref, x)->isapprox(ref, x; atol=10)
    @test_reference joinpath(refdir, "string4.txt") strip_summary(@io2str show(::IO, MIME"text/plain"(), Int64.(collect(1:5))))

    # ignore CRLF/LF differences
    @test_reference joinpath(refdir, "string5.txt") """
        This is a\r
        multiline string that does not end with a new line."""
    @test_reference joinpath(refdir, "string5.txt") """
        This is a
        multiline string that does not end with a new line."""

    @test_reference joinpath(refdir, "string6.txt") """
        This on the other hand is a
        multiline string that does indeed end with a new line.
    """

    @test_throws ErrorException @test_reference joinpath(refdir, "string1.txt") "intentionally wrong to check that this message prints"
    @test_throws ErrorException @test_reference joinpath(refdir, "string5.txt") """
        This is an incorrect
        multiline string that does not end with a new line."""
end

@testset "string as SHA" begin
    @test_reference joinpath(refdir, "number1.sha256") 1337
    foo = "foo"
    @test_reference joinpath(refdir, "string1.sha256") foo * "bar"
    A = ones(30,30)
    @test_reference joinpath(refdir, "string2.sha256") @io2str show(IOContext(::IO, :limit=>true, :displaysize=>(5,5)), A)
end

@testset "plain ansi string" begin
    @test_reference(
        joinpath(refdir, "ansii.txt"),
        @io2str(printstyled(IOContext(::IO, :color=>true), "this should be blue", color=:blue)),
        render = ReferenceTests.BeforeAfterFull()
    )
    @test_throws ErrorException @test_reference(
        joinpath(refdir, "ansii.txt"),
        @io2str(printstyled(IOContext(::IO, :color=>true), "this should be red", color=:red)),
        render = ReferenceTests.BeforeAfterFull()
    )
end

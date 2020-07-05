@testset "io2str" begin
    @test_throws LoadError eval(@macroexpand @io2str(::IO))
    @test_throws ArgumentError @io2str(2)
    @test_throws ArgumentError @io2str(string(2))
    @test @io2str(print(::IO, "foo")) == "foo"
    @test @io2str(println(::IO, "foo")) == "foo\n"
    @test @io2str(show(::IO, "foo")) == "\"foo\""
    A = ones(30,30)
    @test @io2str(show(IOContext(::IO, :limit => true, :displaysize => (5,5)), A)) == "[1.0 1.0 … 1.0 1.0; 1.0 1.0 … 1.0 1.0; … ; 1.0 1.0 … 1.0 1.0; 1.0 1.0 … 1.0 1.0]"
end

@testset "withcolor" begin
    @test_throws ArgumentError @withcolor throw(ArgumentError("foo"))
    @test @withcolor Base.have_color == true
    @test @withcolor @io2str(printstyled(IOContext(::IO, :color => true), "test", color=:green)) == "\e[32mtest\e[39m"
end

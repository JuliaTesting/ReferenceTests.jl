using Base.Test
using TestSetExtensions
using ReferenceTests


@testset "all the tests" begin

    @testset ExtendedTestSet "Multiline String" begin
        @test_reference "references/multilinestring1.txt" """
            Julia is a modern language
            for technical computing
            With applications is:
             - Scientific Computing
             - Data Science
             - General Purpose Computing by people who are already using julia
             - (Suprisingly) Shell Scripting
        """
    end


    @testset ExtendedTestSet "Arrays" begin
        @test_reference "references/array1.txt" gcd.(102, [10, 27, 26, 3333331])
    end

end

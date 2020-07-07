refdir = joinpath(refroot, "dataframe")

@testset "DataFrame as CSV" begin
    @test_reference joinpath(refdir, "dataframe.csv") DataFrame(v1=[1,2,3], v2=["a","b","c"])
    @test_throws ErrorException @test_reference joinpath(refdir, "dataframe.csv") DataFrame(v1=[1,2,3], v2=["c","b","c"])

end

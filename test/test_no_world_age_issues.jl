@testset "world age issues" begin
    files = ["references/camera.png"]

    for filename in files
        @test_reference filename load(joinpath(@__DIR__, filename))
    end
end

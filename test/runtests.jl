using ImageInTerminal, Base.Test, ColorTypes

# check for ambiguities
refambs = detect_ambiguities(ImageInTerminal, Base, Core)
using ReferenceTests
ambs = detect_ambiguities(ReferenceTests, ImageInTerminal, Base, Core)
@test length(setdiff(ambs, refambs)) == 0

@test_reference "references/myfile.txt" "hello"
@test_reference "references/img1.txt" rand(RGB, 10, 10)

# @test_reference "img1.png" rand(RGB, 10, 10)
# @test_reference "img1.txt" rand(RGB, 10, 10)

# @test_reference "rand" rand(10, 10)
# @test_reference "rand.csv" rand(10, 10)
# @test_reference "rand.csv" DataTable(v1=[1,2,3], v2=["a","b","c"])

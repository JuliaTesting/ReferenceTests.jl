using ReferenceTests
using Base.Test

# write your own tests here
@test 1 == 2

@test_reference "img1.png" rand(RGB, 10, 10)
@test_reference "img1.txt" rand(RGB, 10, 10)

@test_reference "rand" rand(10, 10)
@test_reference "rand.csv" rand(10, 10)
@test_reference "rand.csv" DataTable(v1=[1,2,3], v2=["a","b","c"])

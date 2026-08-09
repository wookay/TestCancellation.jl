module test_testcancellation_sleep

using TestCancellation

# from julia/test/cancellation.jl

# @testset "cancellation of waiting tasks" begin
# Cancellation of `sleep`
t, src = cancellable(() -> sleep(1000; cancel=Base.DEFAULT_CANCEL))
spin()
cancel!(src)
expect_cancelled(t)

end # module test_testcancellation_sleep

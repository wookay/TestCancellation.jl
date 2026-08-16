module test_testcancellation_task

using Test
using TestCancellation

# from julia/test/cancellation.jl

# @testset "subscriptions die with their birth source" begin
# born cancelled: refused at subscribe, never enqueued
src = CancellationTokenSource()
t2 = with(() -> Task(() -> 42), CANCEL_TOKEN => CancellationToken(src))
c = Threads.Condition()
@lock c Base.schedule_on_notify!(c, t2)
@test !istaskdone(t2)
@test !istaskfailed(t2)
cancel!(src)
spin()
@test istaskdone(t2)
@test istaskfailed(t2)
@test t2.result isa CancellationRequest
@test Base.severity(t2.result) == Base.severity(CANCEL_REQUEST_SAFE)

end # module test_testcancellation_task

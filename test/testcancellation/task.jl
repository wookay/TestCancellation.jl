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

# Cancelling a scope reaches a task waiting on another task; the waited-on
# task (in the same scope) is cancelled through the same tree
let t_in
t, src = cancellable() do
    t_in = @async sleep(1000)
    wait(t_in)
end
spin()
cancel!(src)
@test_throws TaskFailedException wait(t)
@test timedwait(() -> istaskdone(t_in), 10.0) === :ok # :timed_out
@test istaskfailed(t_in)
end # let

let t_in
t, src = cancellable() do
    t_in = @async sleep(1000)
    wait(t_in)
end
spin()
cancel!(src)
@test_throws CancellationRequest wait(t; cancel=CancellationToken(src))
@test timedwait(() -> istaskdone(t_in), 10.0) === :ok # :timed_out
@test istaskfailed(t_in)
end # let

end # module test_testcancellation_task

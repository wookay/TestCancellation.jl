module test_testcancellation_loop

using Test
using TestCancellation

# from julia/test/cancellation.jl

# @testset "cooperative cancellation of running tasks" begin
t, src = cancellable_spawn() do
    while true
        Base.@cancel_check
        yield() # let the canceller run when there is only one thread
    end
end
cancel!(src)
@test istaskdone(t)
@test istaskfailed(t)

@test t.result isa CancellationRequest
@test Base.severity(t.result) == Base.severity(CANCEL_REQUEST_SAFE)


# @testset "escalation during @sync teardown keeps awaiting internal tasks" begin
stop = Ref(false)
started = Base.Event()
t, src = cancellable() do
    @sync begin
        @async begin
            notify(started)
            while !stop[]
                yield() # no cancellation points: ignores SAFE/ABANDON_EXTERNAL
            end
        end
    end
end
wait(started)
cancel!(src, CANCEL_REQUEST_ABANDON_EXTERNAL)
@test !istaskdone(t)
@test !istaskfailed(t)

stop[] = true
spin()

@test t.result isa CancellationRequest
@test Base.severity(t.result) == Base.severity(CANCEL_REQUEST_ABANDON_EXTERNAL)
@test istaskdone(t)
@test istaskfailed(t)

end # module test_testcancellation_loop

module test_testcancellation_loop

using Test
using Base: CancellationTokenSource, CancellationToken, CancellationRequest, cancel!,
            CANCEL_TOKEN, CANCEL_REQUEST_ABANDON_EXTERNAL, CANCEL_REQUEST_SAFE
using Base.ScopedValues: with

# from julia/test/cancellation.jl

# Threads.@spawn-style cancellable task (non-sticky, explicitly on the
# default pool - a compute-bound victim must not land on the interactive/io
# thread); returns (task, source).
function cancellable_spawn(f)
    src = CancellationTokenSource()
    t = with(() -> Threads.@spawn(f()), CANCEL_TOKEN => CancellationToken(src))
    return t, src
end

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

# Start `f` as an @async-style (sticky, co-scheduled) task governed by a
# fresh cancellation source; returns (task, source).
function cancellable(f)
    src = CancellationTokenSource()
    t = with(() -> @async(f()), CANCEL_TOKEN => CancellationToken(src))
    return t, src
end

# wait a little, so cancellation targets are (most likely) started and parked
spin(n=3) = for _ in 1:n; yield(); end

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

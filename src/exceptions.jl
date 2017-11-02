abstract type NoDecision <: Exception end
Base.show(io::IO, nd::NoDecision) = print(io, """
    Planner failed to choose an action because the following exception was thrown:
    $nd

    To specify an action for this case, use the default_action solver parameter.
    """)

immutable AllSamplesTerminal <: NoDecision
    belief
end
Base.show(io::IO, ast::AllSamplesTerminal) = print(io, """
    Planner failed to choose an action because all states sampled from the belief were terminal.

    To see the belief, catch this exception as ex and see ex.belief.
    
    To specify an action for this case, use the default_action solver parameter.
    """)


immutable ExceptionRethrow end

default_action(::ExceptionRethrow, belief, ex) = rethrow(ex)
default_action(f::Function, belief, ex) = f(belief, ex)
default_action(p::POMDPs.Policy, belief, ex) = action(p, belief)
default_action(a, belief, ex) = a

"""
    ReportWhenUsed(a)

When the planner fails, returns action `a`, but also prints the exception.
"""
immutable ReportWhenUsed{T}
    a::T
end

function default_action(r::ReportWhenUsed, belief, ex)
    showerror(STDERR, ex)
    warn("Using default action $(r.a)")
    return r.a
end

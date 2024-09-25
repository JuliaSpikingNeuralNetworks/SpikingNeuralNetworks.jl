function sim!(P::Vector{AbstractNeuron}, C::Vector{AbstractSynapse}, dt::Float32)
    # Threads.@threads 
    for p in P
        hasfield(typeof(p), :t) && (p.t[1] += 1)
        integrate!(p, getfield(p, :param), dt)
        record!(p)
    end
    # Threads.@threads 
    for c in C
        hasfield(typeof(c), :t) && (c.t[1] += 1)
        forward!(c, getfield(c, :param))
        record!(c)
    end
end

function sim!(
    P::Vector{AbstractNeuron},
    C::Vector{AbstractSynapse};
    dt = 0.1f0,
    duration = 10.0f0,
    pbar = false,
)
    dt = Float32(dt)
    duration = Float32(duration)
    dts = 0.0f0:dt:(duration-dt)
    pbar = pbar ? ProgressBar(dts) : dts
    for t in pbar
        sim!(P, C, dt)
    end
end

function train!(P::Vector{AbstractNeuron}, C::Vector{AbstractSynapse}, dt::Float32)
    for p in P
        hasfield(typeof(p), :t) && (p.t[1] += 1)
        integrate!(p, p.param, dt)
        record!(p)
    end
    for c in C
        hasfield(typeof(c), :t) && (c.t[1] += 1)
        forward!(c, c.param)
        hasfield(typeof(c), :t) && (c.t[2] ≈ 0 && continue)
        plasticity!(c, c.param, dt)
        record!(c)
    end
end

function train!(
    P::Vector{AbstractNeuron},
    C::Vector{AbstractSynapse};
    dt = 0.1ms,
    duration = 10ms,
)
    dt = Float32(dt)
    pbar = ProgressBar(0.0f0:dt:(duration-dt))
    # pbar = 0.0f0:dt:(duration-dt)
    for t in pbar
        train!(P, C, dt)
    end
end

export sim!, train!

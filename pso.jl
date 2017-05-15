# using Images
import Base.size

type Particle
    x
    v    
    best_x
end
function Particle(x, v)
    Particle(x, v, x)
end


type Swarm <: AbstractArray{Float64, 1}    
    particles::Array{Particle, 1}
    best_x
    w
    c1
    c2
    fitness
end
Base.size(S::Swarm) = Base.size(S.particles)
Base.getindex(S::Swarm, I...) = Base.getindex(S.particles, I...)


"""
    Swarm(n::Int, generator, fitness, w=0.9, c1=0.9, c2=0.9)

Construct the particle swarm.

...
# Arguments
* `n::Int`: the number of the swarm.
* `generator`: the function generating a particle.
* `fitness`: fitness function. The lower value is the better.
...

"""
function Swarm(n::Int, generator, fitness, w=0.9, c1=0.9, c2=0.9)
    particles = [generator() for _ in 1:n]
    best_x = sort(particles, by=(p)->fitness(p.x))[1].x
    Swarm(particles, best_x, w, c1, c2, fitness)
end

"""Update the swarm"""
function update!(S::Swarm)
    for p in S
        p.x = p.x + p.v
        newf = S.fitness(p.x)
        if newf < S.fitness(p.best_x)
            p.best_x = p.x  
        end
        if newf < S.fitness(S.best_x)
            S.best_x = p.x
        end
        p.v = S.w *  p.v + S.c1 * rand() * (p.best_x - p.x) + S.c2 * rand() * (S.best_x -  p.x)
    end
end

img = load("hoge.png")


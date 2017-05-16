using Images, Distances
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

function dmin(x)
    d = pairwise(Euclidean(), x')
    cmax, rmax = size(d)
    (d[c, r] for c in 1:cmax for r in (c+1):rmax) |> minimum
end

function minpos(x,fun)
    findfirst(sortperm(x, by=fun), 1)
end

function classify(x, image)
    cls = zeros(Int, size(image))
    for i in 1:length(image)
        cls[i] = minpos(x, (m)->(euclidean(m, image[i])))
    end
    return cls
end

function dmax(x, image)
    cls = classify(x, image)
    Nc = size(x, 1)
    result = zeros(x)
    for c in 1:Nc
        pixels = image[cls .== c]
        result[c] = ((euclidean(x[c], p) for p in pixels) |> sum) / size(pixels, 1)
    end
    return maximum(result)
end

function f(x, image, w1=0.5, w2=0.5)
    w1 * dmax(x, image) + w2 * (maximum(image) - dmin(x))
end

function generate()
    Particle()
end



Nb = 1
Nc = 5
brain = load("brain.png")
img = Float64.(brain)
Swarm(10, ()->Particle(rand(Nc), rand(Nc)), (x)->f(x, img))




# canvas, _ = imshow(brain)
# imshow(canvas, brain .> mean(brain))
# save("bin.png", Gray.(brain .> mean(brain)))

# cls = classify(collect(0:0.1:1), brain)
# imshow(c, scaleminmax(1,11)(cls) )

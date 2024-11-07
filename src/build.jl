# code to create the file sysstate.jl (and later a lot more)
using YAML, OrderedCollections

include("yaml_utils.jl")

HEADER = """
\"\"\"
    SysState{P}

Basic system state. One of these is saved per time step. P is the number
of tether particles.

\$(TYPEDFIELDS)
\"\"\"
Base.@kwdef mutable struct SysState{P}"""
FOOTER = "end"
inputfile = joinpath("data", "sysstate.yaml")
outputfile = joinpath("src", "sysstate.jl")
outputfile2 = joinpath("src", "show.jl")

# read the file sysstate.yaml
sysstate = YAML.load_file(inputfile, dicttype=OrderedDict{String,Any})["sysstate"]
lines = readfile(inputfile)
open(outputfile,"w") do io
    println(io, HEADER)
    for key in keys(sysstate)
        comment = get_comment(lines, key)
        println(io, "    " * comment)
        default = "= 0"
        if sysstate[key] == "MVector{4, Float32}"
            default = "= [1.0, 0.0, 0.0, 0.0]"
        elseif sysstate[key] == "MVector{3, MyFloat}"
            default = "= [0.0, 0.0, 0.0]"
        elseif sysstate[key] == "MVector{P, MyFloat}"
            default = "= zeros(P)"
        end
        println(io, "    " * key * "::" * sysstate[key] * " " * default)   
    end
    println(io, FOOTER)
end
HEADER = "function Base.show(io::IO, st::SysState)" 
open(outputfile2,"w") do io
    println(io, HEADER)
    for key in keys(sysstate)
        unit = get_unit(lines, key)
        description = rpad(key * " " * unit * ":", 19, " ") 
        println(io, "    println(io, \"" * description * "\", st." * key * ")")
    end
    println(io, "end")
end
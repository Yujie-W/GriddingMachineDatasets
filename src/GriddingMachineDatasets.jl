module GriddingMachineDatasets

using JuliaUtilities.PkgUtility: pretty_display!


include("io/input.jl");

include("json/attribute.jl");
include("json/data.jl");
include("json/griddingmachine.jl");
include("json/map.jl");


end # module

#
# This file is meant to config the JSON file to aid further steps
#
using JSON


include("src/json/attribute.jl");
include("src/json/data.jl");
include("src/json/griddingmachine.jl");
include("src/json/map.jl");


"""

    griddingmachine_json!(filename::String = "test.json")

Create a JSON file to generate GriddingMachine dataset, given
- `filename` File name of the json file to save

"""
function griddingmachine_json!(filename::String = "test.json")
    # create a dict to save as JSON file
    _json_dict = Dict{String,Any}(
        "GRIDDINGMACHINE" => griddingmachine_dict(),
        "INPUT_MAP_SETS"  => map_info_dict(),
        "INPUT_VAR_SETS"  => variable_dicts(),
        "OUTPUT_REF_ATTR" => reference_attribute_dict(),
        "OUTPUT_VAR_ATTR" => variable_attribute_dict(),
    );

    # save the JSON file
    _filename = filename[end-4:end] == ".json" ? filename : "$(filename).json";
    open(_filename, "w") do f
        JSON.print(f, _json_dict, 4);
    end;

    return nothing
end

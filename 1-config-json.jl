#
# This file is meant to config the JSON file to aid further steps
#
using JSON


"""

    map_setup_dict()

Create the Dict that stores information about the map settings

"""
function map_setup_dict()
    @info "These inputs are meant to determine what changes are required to pre-process the dataset...";

    # ask the format of input dataset
    print("    What is the format of the input dataset? (NetCDF or GeoTIFF) > ");
    _format = uppercase(readline());
    @assert _format in ["G", "GEOTIFF", "N", "NETCDF", "TIFF"] "The dataset must be NetCDF or GeoTIFF!";

    # ask the projection of the map
    print("    What is the projection of the dataset? (Cylindrical or Sinusoidal) > ");
    _projection = uppercase(readline());
    @assert _projection in ["C", "CYLINDRICAL", "S", "SINUSOIDAL"] "The dataset projection must be within Cylindrical and Sinusoidal!";

    # ask for value of representation
    print("    What does the value represent? (Center or Edge) > ");
    _represent = uppercase(readline());
    @assert _represent in ["C", "CENTER", "E", "EDGE"] "You must choose one from Center or Edge!";

    # ask and parse map coverage
    print("    What is the coverage of the dataset? (Global or not; if not global, type in the conner values in the order or min lat, max lat, min lon, max lon) > ");
    _coverage = uppercase(readline());
    if occursin(",", _coverage)
        _conners = [parse(Float64, _str) for _str in split(_coverage, ",")];
        @assert -90 <= _conners[1] < _conners[2] <= 90 "Latitude must be within -90 to 90";
        @assert ((-180 <= _conners[3] < _conners[4] <= 180) || 0 <= _conners[3] < _conners[4] <= 360) "Longitude must be within -180 to 180 or 0 to 360";
    else
        @assert _coverage in ["G", "GLOBAL"] "You need to guarantee the coverage input is correct";
    end;
    _coverages = (_coverage in ["G", "GLOBAL"] ? "Global" : [parse(Float64, _str) for _str in split(_coverage, ",")]);

    # ask for re-oritentation of the map
    print("    Do you need to re-orient the map on the latitudinal direction? (Yes or No) > ");
    _reorient_lat = uppercase(readline());
    @assert _reorient_lat in ["N", "NO", "Y", "YES"];
    _flip_lat = _reorient_lat in ["Y", "YES"];
    print("    Do you need to re-orient the map on the longitudinal direction? (Yes or No) > ");
    _reorient_lon = uppercase(readline());
    @assert _reorient_lon in ["N", "NO", "Y", "YES"];
    _flip_lon = _reorient_lon in ["Y", "YES"];

    # return the Dict for raw dataset settings
    return Dict{String,Any}(
        "FORMAT"           => _format,
        "PROJECTION"       => _projection,
        "VALUE_AT"         => _represent,
        "COVERAGE"         => _coverages,
        "LAT_LON_FLIPPING" => [_flip_lat, _flip_lon],
    )
end


"""

    variable_dicts()

Create a vector of Dicts that store variable information

"""
function variable_dicts()
    @info "These questions are about how to read the data, please be careful about them...";

    # ask for how many independent variables do you want to save as DATA
    print("    How many variables do you want to save as DATA (e.g., combine data1 and data2 in one netcdf file) > ");
    _data_count = parse(Int, readline());
    _data_dicts = Dict{String,Any}[];
    for _i_data in 1:_data_count
        println("    For data label $(_i_data):");
        print("        What is the label name or band name? > ");
        _data_name = readline();
        print("        What is the longitude axis number of the data? (e.g., 1 for [lon,lat,time] and 2 for [lat,lon,time]) > ");
        _i_lon = parse(Int, readline());
        print("        What is the latitude axis number of the data? (e.g., 2 for [lon,lat,time] and 1 for [lat,lon,time]) > ");
        _i_lat = parse(Int, readline());
        print("        What is the index axis number of the data? (e.g., 3 for time in [lon,lat,time] and empty for [lat,lon]) > ");
        _i_ind = readline();
        _i_idx = (_i_ind == "" ? nothing : parse(Int, _i_ind));
        print("        If you have extra scaling you want to make, type it here (NCDatasets may do that already, need to double check, example: x -> log(x)) > ");
        _scaling_function = readline();
        print("        What are your mask function for NaN, type it here, e.g., x -> (0.1 < x <= 0.2 && x * 6 > 1) > ");
        _masking_function = readline();
        _data_dict = Dict{String,Any}(
            "DATA_NAME"            => _data_name,
            "LONGITUDE_AXIS_INDEX" => _i_lon,
            "LATITUDE_AXIS_INDEX"  => _i_lat,
            "INDEX_AXIS_INDEX"     => _i_idx,
            "SCALING_FUNCTION"     => _scaling_function,
            "MASKING_FUNCTION"     => _masking_function,
        );
        push!(_data_dicts, _data_dict);
    end;

    return _data_dicts
end


"""

    griddingmachine_json!(filename::String = "test.json")

Create a JSON file to generate GriddingMachine dataset, given
- `filename` File name of the json file to save

"""
function griddingmachine_json!(filename::String = "test.json")
    # create a dict to save as JSON file
    _json_dict = Dict{String,Any}(
        "GRIDDINGMACHINE"        => griddingmachine_dict(),
        "INPUT_DATASET_SETTINGS" => map_setup_dict(),
        "VARIABLE_SETTINGS"      => variable_dicts(),
        "NETCDF_ATTRIBUTES"      => variable_attribute_dict(),
    );

    # save the JSON file
    _filename = filename[end-4:end] == ".json" ? filename : "$(filename).json";
    open(_filename, "w") do f
        JSON.print(f, _json_dict, 4);
    end;

    return nothing
end

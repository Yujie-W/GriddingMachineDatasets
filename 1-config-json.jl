#
# This file is meant to config the JSON file to aid further steps
#
using JSON


"""

    griddingmachine_dict()

Create a Dict that stores information about GriddingMachine tag

"""
function griddingmachine_dict()
    @info "These inputs are meant to generate the GriddingMachine TAG...";

    # ask for level 1 label
    print("    Please indicate the level 1 label for the dataset (e.g., GPP as in GPP_VPM_2X_1M_V1) > ");
    _label = uppercase(readline());
    @assert _label != "" "Label must not be empty!";

    # ask and parse extra labels
    print("    Please indicate the level 2 label for the dataset (e.g., VPM as in GPP_VPM_2X_1M_V1, leave empty is there is not any) > ");
    _label_extra = uppercase(readline());
    _label_extra = (_label_extra == "" ? nothing : _label_extra);

    # ask and parse spatial resolution
    print("    Please indicate the spatial resolution represented with an integer (N for 1/N °) > ");
    _spatial_resolution_nx = parse(Int, readline());
    @assert _spatial_resolution_nx > 0 "Spatial resolution must not be smaller than 1";

    # ask for temporal resolution
    print("    Please indicate the temporal resolution (e.g., 8D, 1M, and 1Y) > ");
    _temporal_resolution = uppercase(readline());
    @assert _temporal_resolution != "" "Temporal resolution cannot be empty";

    # ask and parse year range
    print("    Please indicate the range of years (e.g., 2001:2022, and 2001,2005, empty for non-specific) > ");
    _years_input = readline();
    _years = "";
    if _years_input == ""
        _years = nothing;
    elseif occursin(":", _years_input)
        _years_str = split(_years_input, ":");
        if length(_years_str) == 2
            _min = parse(Int, _years_str[1]);
            _max = parse(Int, _years_str[2]);
            _years = _min:_max;
        else length(_years_str) > 2
            _min = parse(Int, _years_str[1]);
            _stp = parse(Int, _years_str[2]);
            _max = parse(Int, _years_str[3]);
            _years = _min:_stp:_max;
        end;
    elseif occursin(",", _years_input)
        _years_str = split(_years_input, ",");
        _years = [parse(Int, _str) for _str in _years_str];
    else
        _years = [parse(Int, _years_input)];
    end;

    # ask for version info
    print("    Please indicate the version number of the dataset (1 for V1) > ");
    _version = parse(Int, readline());
    @assert _version > 0 "version number must not be smaller than 1";

    # display information about the tag
    _labeling = isnothing(_label_extra) ? _label : _label * "_" * _label_extra;
    if isnothing(_years)
        @info "The GriddingMachine tag will be $(_labeling)_$(_spatial_resolution_nx)X_$(_temporal_resolution)_V$(_version)";
    else
        @info "The GriddingMachine tag will be $(_labeling)_$(_spatial_resolution_nx)X_$(_temporal_resolution)_YEAR_V$(_version)";
    end;

    # return the dict for GriddingMachine
    return Dict{String,Any}(
        "LABEL"               => _label,
        "EXTRA LABEL"         => _label_extra,
        "SPATIAL RESOLUTION"  => _spatial_resolution_nx,
        "TEMPORAL RESOLUTION" => _temporal_resolution,
        "YEARS"               => _years,
        "VERSION"             => _version,
    )
end


"""

    attribute_dict()

Create a Dict that stores information about variable attributes

"""
function variable_attribute_dict()
    @info "These inputs are meant to generate the reference information witin the Netcdf dataset...";

    # ask for the long name, unit, and about of the variable
    print("    Please input the long name of the variable to save > ");
    _longname = readline();
    print("    Please input the unit of the variable to save > ");
    _unit = readline();
    print("    Please input some more details of the variable to save > ");
    _about = readline();
    print("    Please input the author information (e.g., Name S. et al.) > ");
    _authors = readline();
    print("    Please input the year of the publication > ");
    _year_pub = parse(Int,readline());
    print("    Please input the title of the publication > ");
    _title = readline();
    print("    Please input the journal of the publication > ");
    _journal = readline();
    print("    Please input the DOI of the publication > ");
    _doi = readline();

    # return the Dict for attributes
    return Dict{String,Any}(
        "LONG NAME" => _longname,
        "UNIT"      => _unit,
        "ABOUT"     => _about,
        "AUTHORS"   => _authors,
        "YEAR"      => _year_pub,
        "TITLE"     => _title,
        "JOURNAL"   => _journal,
        "DOI"       => _doi,
    )
end


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
        "VALUE AT"         => _represent,
        "COVERAGE"         => _coverages,
        "LAT LON FLIPPING" => [_flip_lat, _flip_lon],
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
            "DATA NAME"            => _data_name,
            "LONGITUDE AXIS INDEX" => _i_lon,
            "LATITUDE AXIS INDEX"  => _i_lat,
            "INDEX AXIS INDEX"     => _i_idx,
            "SCALING FUNCTION"     => _scaling_function,
            "MASKING FUNCTION"     => _masking_function,
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
        "INPUT DATASET SETTINGS" => map_setup_dict(),
        "VARIABLE SETTINGS"      => variable_dicts(),
        "NETCDF ATTRIBUTES"      => variable_attribute_dict(),
    );

    # save the JSON file
    _filename = filename[end-4:end] == ".json" ? filename : "$(filename).json";
    open(_filename, "w") do f
        JSON.print(f, _json_dict, 4);
    end;

    return nothing
end

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

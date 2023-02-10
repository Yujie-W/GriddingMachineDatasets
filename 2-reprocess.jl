using JSON

using JuliaUtilities.NetcdfIO: read_nc, save_nc!


function read_data_2d(data::Array, ind::Int, dict::Dict, flipping::Vector; scaling_function::Union{Function,Nothing} = nothing)
    # read the layer based on the index orders
    if isnothing(dict["INDEX_AXIS_INDEX"])
        if dict["LONGITUDE_AXIS_INDEX"] == 1 && dict["LATITUDE_AXIS_INDEX"] == 2
            _eata = data;
        else
            _eata = data';
        end;
    else
        if dict["INDEX_AXIS_INDEX"] == 3
            if dict["LONGITUDE_AXIS_INDEX"] == 1 && dict["LATITUDE_AXIS_INDEX"] == 2
                _eata = data[:,:,ind];
            else
                _eata = data[:,:,ind]';
            end;
        elseif dict["INDEX_AXIS_INDEX"] == 2
            if dict["LONGITUDE_AXIS_INDEX"] == 1 && dict["LATITUDE_AXIS_INDEX"] == 3
                _eata = data[:,ind,:];
            else
                _eata = data[:,ind,:]';
            end;
        elseif dict["INDEX_AXIS_INDEX"] == 1
            if dict["LONGITUDE_AXIS_INDEX"] == 2 && dict["LATITUDE_AXIS_INDEX"] == 3
                _eata = data[ind,:,:];
            else
                _eata = data[ind,:,:]';
            end;
        end;
    end;

    # flip the lat and lons
    _fata = flipping[1] ? _eata[:,end:-1:1] : _eata;
    _gata = flipping[2] ? _fata[end:-1:1,:] : _fata;

    # add a scaling function
    _hata = isnothing(scaling_function) ? _gata : scaling_function.(_gata);

    return _hata
end


function read_data(filename::String, dict::Dict, flipping::Vector; scaling_function::Union{Function,Nothing} = nothing)
    _data = read_nc(filename, dict["DATA_NAME"]);

    # rotate the data if necessary
    if isnothing(dict["INDEX_AXIS_INDEX"])
        return read_data_2d(_data, 1, dict, flipping; scaling_function = scaling_function)
    else
        _eata = zeros(Float64, size(_data, dict["LONGITUDE_AXIS_INDEX"]), size(_data, dict["LATITUDE_AXIS_INDEX"]), size(_data, dict["INDEX_AXIS_INDEX"]));
        for _ind in axes(_data, dict["INDEX_AXIS_INDEX"])
            _eata[:,:,_ind] .= read_data_2d(_data, _ind, dict, flipping; scaling_function = scaling_function);
        end;

        return _eata
    end;
end


function griddingmachine_tag(dict::Dict, year::Int)
    _dict_grid = dict["GRIDDINGMACHINE"];
    _years = _dict_grid["YEARS"];
    _label = _dict_grid["LABEL"];
    _label_extra = _dict_grid["EXTRA_LABEL"];
    _labeling = isnothing(_label_extra) ? _label : _label * "_" * _label_extra;
    _spatial_resolution_nx = _dict_grid["SPATIAL_RESOLUTION"];
    _temporal_resolution = _dict_grid["TEMPORAL_RESOLUTION"];
    _version = _dict_grid["VERSION"];

    if _years == ""
        _tag = "$(_labeling)_$(_spatial_resolution_nx)X_$(_temporal_resolution)_V$(_version)";
    else
        _tag = "$(_labeling)_$(_spatial_resolution_nx)X_$(_temporal_resolution)_$(year)_V$(_version)";
    end;

    return _tag
end


function reprocess_data!(dict::Dict; file_name_function::Union{Function,Nothing} = nothing, variable_scaling_functions::Vector = [nothing for _i in eachindex(dict["VARIABLE_SETTINGS"])])
    _dict_file = dict["INPUT_DATASET_SETTINGS"];
    _dict_grid = dict["GRIDDINGMACHINE"];
    _dict_vars = dict["VARIABLE_SETTINGS"];

    # determine if there is any information for years
    _years = _dict_grid["YEARS"];
    _files = [];
    if _years == ""
        push!(_files, _dict_file["FOLDER"] * "/" * _dict_file["FILE_NAME_PATTERN"]);
    else
        for _year in _years
            push!(_files, _dict_file["FOLDER"] * "/" * replace(_dict_file["FILE_NAME_PATTERN"], "XXXXXXXX" => file_name_function(_year)));
        end;
    end;

    # work on the first data to test
    _file = _files[1];
    if length(_dict_vars) == 1
        _reprocessed_data = read_data(_file, _dict_vars[1], _dict_file["LAT_LON_FLIPPING"]; scaling_function = variable_scaling_functions[1]);
    else
        _reprocessed_data = ones(Float64, 360 * _dict_grid["SPATIAL_RESOLUTION"], 180 * _dict_grid["SPATIAL_RESOLUTION"], length(_dict_vars));
        for _i_var in eachindex(_dict_vars)
            _reprocessed_data[:,:,_i_var] = read_data(_file, _dict_vars[_i_var], _dict_file["LAT_LON_FLIPPING"]; scaling_function = variable_scaling_functions[_i_var]);
        end;
    end;

    # save the file
    _tag = griddingmachine_tag(dict, _years[1]);
    _reprocessed_file = "/home/wyujie/GriddingMachine/reprocessed/$(_tag).nc";
    _var_attribute = Dict{String,String}(dict["NETCDF_ATTRIBUTES"]);

    # add change logs based on the JSON file
    #=
    - Add uncertainty (filled with NaN)
    - Make the map to global scale (fill with NaN)
    - Reformatted from GeoTIFF or binary to NetCDF
    - Latitude and Longitude re-oriented to from South to North and from West to East
    - Data scaling removed (from log(x), exp(x), or kx+b to x)
    - Data regridded to coarser resolution by averaging all data falling into the new grid
    - Unit standardization
    - Reorder the dimensions to (lon, lat, ind)
    - Unrealistic values to NaN
    =#
    # _count = 0;
    # push!()

    save_nc!(_reprocessed_file, "data", _reprocessed_data, _var_attribute);

    return nothing
end


using Dates

local_json_dict = JSON.parse(open("json/VCF_2X_1Y_V1.json"));
local_name_function = eval(Meta.parse(local_json_dict["INPUT_DATASET_SETTINGS"]["FILE_NAME_FUNCTION"]));
local_scaling_functions = [_dict["SCALING_FUNCTION"] == "" ? nothing : eval(Meta.parse(_dict["SCALING_FUNCTION"])) for _dict in local_json_dict["VARIABLE_SETTINGS"]];
local_data = reprocess_data!(local_json_dict; file_name_function = local_name_function, variable_scaling_functions = local_scaling_functions);

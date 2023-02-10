using JSON

using JuliaUtilities.NetcdfIO: read_nc


function read_data_2d(data::Array, ind::Int, dict::Dict, flipping::Vector; scaling_function::Union{Function,Nothing} = nothing)
    # read the layer based on the index orders
    if isnothing(dict["INDEX AXIS INDEX"])
        if dict["LONGITUDE AXIS INDEX"] == 1 && dict["LATITUDE AXIS INDEX"] == 2
            _eata = data;
        else
            _eata = data';
        end;
    else
        if dict["INDEX AXIS INDEX"] == 3
            if dict["LONGITUDE AXIS INDEX"] == 1 && dict["LATITUDE AXIS INDEX"] == 2
                _eata = data[:,:,ind];
            else
                _eata = data[:,:,ind]';
            end;
        elseif dict["INDEX AXIS INDEX"] == 2
            if dict["LONGITUDE AXIS INDEX"] == 1 && dict["LATITUDE AXIS INDEX"] == 3
                _eata = data[:,ind,:];
            else
                _eata = data[:,ind,:]';
            end;
        elseif dict["INDEX AXIS INDEX"] == 1
            if dict["LONGITUDE AXIS INDEX"] == 2 && dict["LATITUDE AXIS INDEX"] == 3
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
    _data = read_nc(filename, dict["DATA NAME"]);

    # rotate the data if necessary
    if isnothing(dict["INDEX AXIS INDEX"])
        return read_data_2d(_data, 1, dict, flipping; scaling_function = scaling_function)
    else
        _eata = zeros(Float64, size(_data, dict["LONGITUDE AXIS INDEX"]), size(_data, dict["LATITUDE AXIS INDEX"]), size(_data, dict["INDEX AXIS INDEX"]));
        for _ind in axes(_data, dict["INDEX AXIS INDEX"])
            _eata[:,:,_ind] .= read_data_2d(_data, _ind, dict, flipping; scaling_function = scaling_function);
        end;

        return _eata
    end;
end


function reprocess_data!(dict::Dict; file_name_function::Union{Function,Nothing} = nothing, variable_scaling_functions::Vector = [nothing for _i in eachindex(dict["VARIABLE SETTINGS"])])
    _dict_file = dict["INPUT DATASET SETTINGS"];
    _dict_grid = dict["GRIDDINGMACHINE"];
    _dict_vars = dict["VARIABLE SETTINGS"];

    # determine if there is any information for years
    _years = dict["GRIDDINGMACHINE"]["YEARS"];
    _files = [];
    if _years == ""
        push!(_files, _dict_file["FOLDER"] * "/" * _dict_file["FILE NAME PATTERN"]);
    else
        for _year in _years
            push!(_files, _dict_file["FOLDER"] * "/" * replace(_dict_file["FILE NAME PATTERN"], "XXXXXXXX" => file_name_function(_year)));
        end;
    end;

    # work on the first data to test
    _file = _files[1];
    if length(_dict_vars) == 1
        _reprocessed_data = read_data(_file, _dict_vars[1], _dict_file["LAT LON FLIPPING"]; scaling_function = variable_scaling_functions[1]);
    else
        _reprocessed_data = ones(Float64, 360 * _dict_grid["SPATIAL RESOLUTION"], 180 * _dict_grid["SPATIAL RESOLUTION"], length(_dict_vars));
        for _i_var in eachindex(_dict_vars)
            _reprocessed_data[:,:,_i_var] = read_data(_file, _dict_vars[_i_var], _dict_file["LAT LON FLIPPING"]; scaling_function = variable_scaling_functions[_i_var]);
        end;
    end;

    return _reprocessed_data
end


using Dates

local_json_dict = JSON.parse(open("json/VCF_2X_1Y_V1.json"));
local_name_function = eval(Meta.parse(local_json_dict["INPUT DATASET SETTINGS"]["FILE NAME FUNCTION"]));
local_scaling_functions = [_dict["SCALING FUNCTION"] == "" ? nothing : eval(Meta.parse(_dict["SCALING FUNCTION"])) for _dict in local_json_dict["VARIABLE SETTINGS"]];
local_data = reprocess_data!(local_json_dict; file_name_function = local_name_function, variable_scaling_functions = local_scaling_functions);

using JSON

using JuliaUtilities.NetcdfIO: append_nc!, read_nc, save_nc!


include("src/json/attribute.jl");
include("src/json/griddingmachine.jl");


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


function reprocess_data!(
            dict::Dict;
            file_name_function::Union{Function,Nothing} = nothing,
            data_scaling_functions::Vector = [nothing for _i in eachindex(dict["VARIABLE_SETTINGS"])],
            std_scaling_functions::Vector = [nothing for _i in eachindex(dict["VARIABLE_SETTINGS"])])
    _dict_file = dict["INPUT_DATASET_SETTINGS"];
    _dict_grid = dict["GRIDDINGMACHINE"];
    _dict_vars = dict["VARIABLE_SETTINGS"];
    _dict_stds = dict["VARIABLE_STD_SETTINGS"];

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

    # iterate through the files
    _i_years = (_years == "" ? [1] : eachindex(_years));
    for _i_year in _i_years
        # determine whether to skip based on the tag
        _tag = (_years == "" ? griddingmachine_tag(dict) : griddingmachine_tag(dict, _years[_i_year]));
        _reprocessed_file = "/home/wyujie/GriddingMachine/reprocessed/$(_tag).nc";

        # reprocess the data only if file does not exist
        if !isfile(_reprocessed_file)
            # read the data
            _file = _files[_i_year]
            if length(_dict_vars) == 1
                _reprocessed_data = read_data(_file, _dict_vars[1], _dict_file["LAT_LON_FLIPPING"]; scaling_function = data_scaling_functions[1]);
                _reprocessed_std = read_data(_file, _dict_stds[1], _dict_file["LAT_LON_FLIPPING"]; scaling_function = std_scaling_functions[1]);
            else
                _reprocessed_data = ones(Float64, 360 * _dict_grid["SPATIAL_RESOLUTION"], 180 * _dict_grid["SPATIAL_RESOLUTION"], length(_dict_vars));
                _reprocessed_std = ones(Float64, 360 * _dict_grid["SPATIAL_RESOLUTION"], 180 * _dict_grid["SPATIAL_RESOLUTION"], length(_dict_vars));
                for _i_var in eachindex(_dict_vars)
                    _reprocessed_data[:,:,_i_var] = read_data(_file, _dict_vars[_i_var], _dict_file["LAT_LON_FLIPPING"]; scaling_function = data_scaling_functions[_i_var]);
                    _reprocessed_std[:,:,_i_var] = read_data(_file, _dict_stds[_i_var], _dict_file["LAT_LON_FLIPPING"]; scaling_function = std_scaling_functions[_i_var]);
                end;
            end;

            # save the file
            _var_attribute = Dict{String,String}(dict["NETCDF_ATTRIBUTES"]);
            _dim_names = length(size(_reprocessed_std)) == 3 ? ["lon", "lat", "ind"] : ["lon", "lat"];
            save_nc!(_reprocessed_file, "data", _reprocessed_data, _var_attribute);
            append_nc!(_reprocessed_file, "std", _reprocessed_std, _var_attribute, _dim_names);
        else
            @info "File $(_reprocessed_file) exists already, skipping...";
        end;
    end;

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

    return nothing
end

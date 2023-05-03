
function reprocess_data!(
            dict::Dict;
            file_name_function::Union{Function,Nothing} = nothing,
            data_scaling_functions::Vector = [nothing for _i in eachindex(dict["VARIABLE_SETTINGS"])],
            std_scaling_functions::Vector = [nothing for _i in eachindex(dict["VARIABLE_SETTINGS"])])
    _dict_file = dict["INPUT_MAP_SETS"];
    _dict_grid = dict["GRIDDINGMACHINE"];
    _dict_vars = dict["INPUT_VAR_SETS"];
    _dict_outv = dict["OUTPUT_VAR_ATTR"];
    _dict_refs = dict["OUTPUT_REF_ATTR"];
    _dict_stds = "INPUT_STD_SETS" in keys(dict) ? dict["INPUT_STD_SETS"] : nothing;

    #"OUTPUT_REF_ATTR" => reference_attribute_dict(),
    #"OUTPUT_VAR_ATTR" => variable_attribute_dict(),

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
                _reprocessed_data = read_data(_file, _dict_vars[1], [_dict_file["FLIP_LAT"],_dict_file["FLIP_LON"]]; scaling_function = data_scaling_functions[1]);
                _reprocessed_std = !isnothing(_dict_stds) ? read_data(_file, _dict_stds[1], [_dict_file["FLIP_LAT"],_dict_file["FLIP_LON"]]; scaling_function = std_scaling_functions[1]) : ones(Float64, 360 * _dict_grid["LAT_LON_RESO"], 180 * _dict_grid["LAT_LON_RESO"]) .* NaN;
            else
                _reprocessed_data = ones(Float64, 360 * _dict_grid["LAT_LON_RESO"], 180 * _dict_grid["LAT_LON_RESO"], length(_dict_vars));
                _reprocessed_std = ones(Float64, 360 * _dict_grid["LAT_LON_RESO"], 180 * _dict_grid["LAT_LON_RESO"], length(_dict_vars)) .* NaN;
                for _i_var in eachindex(_dict_vars)
                    _reprocessed_data[:,:,_i_var] = read_data(_file, _dict_vars[_i_var], [_dict_file["FLIP_LAT"],_dict_file["FLIP_LON"]]; scaling_function = data_scaling_functions[_i_var]);
                    if !isnothing(_dict_stds)
                        _reprocessed_std[:,:,_i_var] = read_data(_file, _dict_stds[_i_var], [_dict_file["FLIP_LAT"],_dict_file["FLIP_LON"]]; scaling_function = std_scaling_functions[_i_var]);
                    end;
                end;
            end;

            # save the file
            _var_attr::Dict{String,String} = merge(_dict_outv,_dict_refs);
            _dim_names = length(size(_reprocessed_std)) == 3 ? ["lon", "lat", "ind"] : ["lon", "lat"];
            save_nc!(_reprocessed_file, "data", _reprocessed_data, _var_attr);
            append_nc!(_reprocessed_file, "std", _reprocessed_std, _var_attr, _dim_names);
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

using ArchGDAL
using NetcdfIO: append_nc!, save_nc!
using Plots


ENV["GKSwstype"] = "100";


GRIDDING_MACHINE_HOME = "/home/wyujie/GriddingMachine";


function read_tiff(datafile::String, label::Int = 1; mask_function = NaN, scaling_function = NaN, transforming::Bool = false, flipping::Bool = false, force_float::Bool = false)
    # read the data
    _tiff = ArchGDAL.read(datafile);
    _band = ArchGDAL.getband(_tiff, label);
    _data = force_float ? Float64.(ArchGDAL.read(_band)) : ArchGDAL.read(_band);

    # apply the mask function
    if typeof(mask_function) <: Function
        _data[mask_function.(_data)] .= NaN;
    end;

    # apply the scaling function
    if typeof(scaling_function) <: Function
        _data = scaling_function.(_data);
    end;

    # transform and flip the data (if necessary)
    _eata = transforming ? _data' : _data;
    _fata = flipping ? _eata[:,end:-1:1] : _eata;

    return _fata
end


function read_data end

read_data(datafile::String, label::Union{Int, String}; args...) = (
    if lowercase(datafile[end-4:end]) == ".tiff" || lowercase(datafile[end-3:end]) == ".tif"
        return read_tiff(datafile, label; args...)
    end;

    return error("File type not supported by function read_data()!")
);

read_data(datafiles::Vector{String}, labels::Union{Vector{Int}, Vector{String}}; args...) = (
    # read the first file to determine the dimensions
    _data_2d = read_data(datafiles[1], labels[1]; args...);
    _data_3d = ones(size(_data_2d)..., length(datafiles));

    # combine the files into one data array
    _data_3d[:,:,1] .= _data_2d;
    for _i in 2:length(datafiles)
        _data_2d = read_data(datafiles[_i], labels[_i]; args...);
        _data_3d[:,:,_i] .= _data_2d;
    end;

    return _data_3d
);


function prepare_data!(artifact_name::String, datafiles::Union{String, Vector{String}}, labels::Union{Int, String, Vector}, var_attributes::Dict{String,String};
                       stdfiles::Union{Nothing, String, Vector{String}} = nothing, stdlabels::Union{Nothing, Int, String, Vector} = nothing, args...)
    # do nothing if file exists
    _reprocessed_file = "$(GRIDDING_MACHINE_HOME)/reprocessed/$(artifact_name).nc";
    if isfile(_reprocessed_file)
        @warn "Reprocessed file exists already, nothing has been done!";
        return nothing
    end

    # read and combine the data and std
    _data = read_data(datafiles, labels; args...);
    _stdv = isnothing(stdfiles) ? similar(_data) .* NaN : read_data(stdfiles, stdlabels; args...);

    # preview the data and std
    _zoom = Int(size(_data,1) / 360);
    _reso = 1 / _zoom;
    _lons = (-180 + 0.5 * _reso):_reso:180;
    _lats = (-90 + 0.5 * _reso):_reso:90;
    if size(_data,3) > 1
        _animation = @animate for _i in axes(_data,3)
            heatmap(_lons[1:_zoom:end], _lats[1:_zoom:end], _data[1:_zoom:end,1:_zoom:end,_i]'; aspect_ratio = :equal);
        end;
        gif(_animation, "$(artifact_name).data.gif");
        _animation = @animate for _i in axes(_data,3)
            heatmap(_lons[1:_zoom:end], _lats[1:_zoom:end], _stdv[1:_zoom:end,1:_zoom:end,_i]'; aspect_ratio = :equal);
        end;
        gif(_animation, "$(artifact_name).stdv.gif");
    else
        _figure = heatmap(_lons[1:_zoom:end], _lats[1:_zoom:end], _data[1:_zoom:end,1:_zoom:end]'; aspect_ratio = :equal);
        savefig(_figure, "$(artifact_name).data.png");
        _figure = heatmap(_lons[1:_zoom:end], _lats[1:_zoom:end], _stdv[1:_zoom:end,1:_zoom:end]'; aspect_ratio = :equal);
        savefig(_figure, "$(artifact_name).stdv.png");
    end;

    # ask user if the preview is okay to proceed
    @info "If the preview looks good, please type [yes] or [YES] to proceed:";
    if lowercase(readline()) != "yes"
        @warn "The results are not satisfactory, and thus not saved. Please check your settings and rerun the function!"
        return nothing
    end;

    # save the data
    _dim_names = (size(_data,3) > 1) ? ["lon", "lat", "ind"] : ["lon", "lat"];
    save_nc!(_reprocessed_file, "data", _data, var_attributes);
    append_nc!(_reprocessed_file, "std", _stdv, var_attributes, _dim_names);

    return nothing
end

function [dataset, metadata] = read_bdata_hdf5(fpath)
% read_bdata_hdf5   Read BData from `fpath`
%
% Note: Only row-major arrays are yet supported.
%
% This file is a part of BrainDecoderToolbox2.
%

fid = H5F.open(fpath);
info = hdf5info(fpath);

% Datasets (dataset)
for i = 1:length(info.GroupHierarchy.Datasets)
    ds = info.GroupHierarchy.Datasets(i);

    if strcmpi(ds.Name, '/dataset')
        dataset_id = H5D.open(fid, ds.Name);
    else
        warning(sprintf('Unsupported dataset %s was ignored.\n', ds.Name));
        continue;
    end

    dataset = H5D.read(dataset_id)';
    H5D.close(dataset_id);
end    

% Groups (metadata, header, vmap)
for i = 1:length(info.GroupHierarchy.Groups)
    gp = info.GroupHierarchy.Groups(i);

    if strcmpi(gp.Name, '/metadata')
        for j = 1:length(gp.Datasets)
            if strcmpi(gp.Datasets(j).Name, '/metadata/key')
                metadata_key_id = H5D.open(fid, gp.Datasets(j).Name);
            elseif strcmpi(gp.Datasets(j).Name, '/metadata/description')
                metadata_desc_id = H5D.open(fid, gp.Datasets(j).Name);
            elseif strcmpi(gp.Datasets(j).Name, '/metadata/value')
                metadata_value_id = H5D.open(fid, gp.Datasets(j).Name);
            else
                error('Invalid field in /metadata');
            end
        end

        metadata.value = H5D.read(metadata_value_id)';

        mdkey_array = H5D.read(metadata_key_id);
        metadata.key = array2cell(mdkey_array);

        mddesc_array = H5D.read(metadata_desc_id);
        metadata.description = array2cell(mddesc_array);

        H5D.close(metadata_key_id);
        H5D.close(metadata_desc_id);
        H5D.close(metadata_value_id);
    elseif strcmpi(gp.Name, '/header')
        warning(sprintf('"header" is not yet supported an was ignored.\n'));
    elseif strcmpi(gp.Name, '/vmap')
        warning(sprintf('"vmap" is not yet supported an was ignored.\n'));
    else
        warning(sprintf('Unsupported group %s was ignored.\n', gp.Name));
        continue;
    end
end

H5F.close(fid);

end


function cellarray = array2cell(array)
% Convert array of strings to cell array

[maxstr, length] = size(array);
cellarray = {};
for i = 1:length
    b = array(:, i)';
    cellarray{i, 1} = b(b >= 1);
end

end

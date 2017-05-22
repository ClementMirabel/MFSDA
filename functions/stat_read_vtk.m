function vertex = stat_read_vtk(file_dir)

    % stat_read_vtk - read data from VTK file.
    %
    % Inputs:
    %     file_dir:
    %                 the string indicating the directory where all vtk files are stored.
    %
    % Output:
    %     vertex     - a n x L0 x 3 matrix specifying the position of the vertices.
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Copyright (c) Mario Richtsfeld, distributed under BSD license
    % http://www.mathworks.com/matlabcentral/fileexchange/5355-toolbox-graph/content/toolbox_graph/read_vtk.m
    % http://www.ifb.ethz.ch/education/statisticalphysics/file-formats.pdf
    % ftp://ftp.tuwien.ac.at/visual/vtk/www/FileFormats.pdf
    % The vtk format supports a wide range of datasets, Chris Rorden modified
    % March, 2017 @ modified by Chao Huang

    %% --- read the file names of all vtk files

    FileNames = dir(sprintf('%s/*.vtk',file_dir));
    FileNames = {FileNames.name}';
    nn=size(FileNames,1);

    for ii=1:nn
        filename=sprintf('%s/%s',file_dir,FileNames{ii});
        vertex(ii,:,:) = stat_read_vtk_file(filename);
    end
end
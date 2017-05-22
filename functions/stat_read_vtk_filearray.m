function vertex = stat_read_vtk_filearray(FileNames)    
    nn=size(FileNames,1);
    for ii=1:nn
        vertex(ii,:,:) = stat_read_vtk_file(FileNames{ii});
    end
end
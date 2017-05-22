function vertex_ii = stat_read_vtk_file(filename)

    fid = fopen(filename,'r');
    if( fid==-1 )
        error('Can''t open the VTK file %s',filename);
    end
    str = fgets(fid);   % -1 if eof, signature, e.g. "# vtk DataFile Version 3.0"
    if ~strcmp(str(3:5), 'vtk')
        error('The file is not a valid VTK one.');
    end
    % read header
    str = fgets(fid); % notes, e.g. "vtk output ImageThreshold=53.0"
    formatStr = fgets(fid); % datatype, "BINARY" or "ASCII"
    isBinary = false;
    if strcmpi(formatStr(1:6), 'BINARY')
        isBinary = true;
    elseif ~strcmpi(formatStr(1:5), 'ASCII')
        error('Only able to read VTK images saved as BINARY or ASCII, not %s', formatStr);
    end
    kindStr = fgets(fid); % kind, e.g. "DATASET POLYDATA" or "DATASET STRUCTURED_ POINTS"
    if isempty(strfind(upper(kindStr),'POLYDATA'))
        error('Only able to read VTK images saved as POLYDATA, not %s', kindStr);
    end
    vertStr = fgets(fid); % number of vertices, e.g. "POINTS 685462 float"
    if isempty(strfind(upper(vertStr),'POINTS'))
        error('Expected header to report "POINTS", not %s', vertStr);
    end
    nvert = sscanf(vertStr,'%*s %d %*s', 1);
    % read vertices
    if isBinary
        cnt = 3*nvert;
        vtx = freafilenamed(fid, cnt, 'float32=>float32');
    else
        [A,cnt] = fscanf(fid,'%f %f %f', 3*nvert);
        str = fgets(fid); %read EOLN for vertices
        if cnt~=3*nvert
            warning('Problem in reading vertices.');
        end
        vertex_ii = reshape(A, 3, cnt/3);        
    end;
    % read polygons
    str = fgets(fid); %e.g. "POLYGONS 6 30"
    info = sscanf(str,'%c %*s %*s', 1);
    if isBinary
        if(info ~= 'P')
            error('Only able to read binary VTK files with POLYGONS: %s', str);
        end
        nface = sscanf(str,'%*s %d %*s', 1);
        cnt = sscanf(str,'%*s %*s %d', 1);
        if (cnt ~= (4 * nface))
            error('Only able to read VTK files with triangles: %s', str);
        end
        A = fread(fid, cnt, 'uint32=>uint32');
        if A(1) ~= 3 %not native endian!!!!
            %A = swapbytes( uint32(A));
            A = swapbytes(A);
            vtx = swapbytes(vtx);
        end
        if A(1) ~= 3 %not native endian!!!!
            error('This vtk file is borked');
        end

        vertex_ii = double(vtx);
        vertex_ii = reshape(vertex_ii, 3, numel(vertex_ii)/3);        
    end
    vertex_ii = vertex_ii';
    fclose(fid);
end
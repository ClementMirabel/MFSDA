function MFSDA_CMD(ShapeDataName, CoordDataName, CovariatesName, CovariateofInterestName, CovariateTypeName, OutputDir, exportJSON)
    
    [pathstr,~,~] = fileparts(mfilename('fullpath'));
    addpath(genpath([pathstr,'/data']));
    addpath(genpath([pathstr,'/functions']));    
    
    try

        ShapeDataFileArray = importdata(ShapeDataName);    
        outputFiles = MFSDA(ShapeDataFileArray, CoordDataName, CovariatesName, CovariateofInterestName, CovariateTypeName, OutputDir);
        
        if(exist('exportJSON') && exportJSON)
            addpath(genpath([pathstr,'/jsonlab-1.5']));            
            cellfun(@(filename)exportToJSON(filename), outputFiles);
        end
    catch e
        fprintf('Error running MFSDA, please check input data: %s', e.message);
    end
    
function exportToJSON(filename)
    try
        [path, name, ~] = fileparts(filename);
        jsonoutputfilename = fullfile(path, [name '.json']);
        fprintf('\n+++Exporting %s to JSON+++\n', filename);
        
        savejson('', load(jsonoutputfilename), );
    catch e
        fprintf('\nError exporting to JSON, please check output data: %s\n', e.message);
    end
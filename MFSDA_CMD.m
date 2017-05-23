function MFSDA_CMD(ShapeDataName, CoordDataName, CovariatesName, CovariateofInterestName, CovariateTypeName, OutputDir)       
    
    [pathstr,~,~] = fileparts(mfilename('fullpath'));
    addpath(genpath([pathstr,'/data']));
    addpath(genpath([pathstr,'/functions']));
    
    try

        ShapeDataFileArray = importdata(ShapeDataName);    
        MFSDA(ShapeDataFileArray, CoordDataName, CovariatesName, CovariateofInterestName, CovariateTypeName, OutputDir);        
    catch
        fprintf('Error running MFSDA, please check input data');
    end
    
    exit

    
    
    
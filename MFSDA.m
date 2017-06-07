function outputFiles = MFSDA(ShapeDataFileArray, CoordDataName, CovariatesName, CovariateofInterestName, CovariateTypeName, OutputDir)


    Ydesign = stat_read_vtk_filearray(ShapeDataFileArray);    % n*L*d matrix
    % Ydesign: the text file containing surface shape information of all vertices.
    % Ydesign is a n x L x m matrix, here m=d
    % n denotes the number of subjects
    % L denotes the number of vertices
    % d denotes the the dimension of the coordinates (2 or 3).
    fprintf('The dimension of shape matrix is %i x %i x %i .\n',size(Ydesign));

    %%
    fprintf('+++++++Read the sphere coordinate data+++++++\n');

    Coord = stat_read_vtk_file(CoordDataName);   % L*d matrix
    % Coord: the text file containing coordinates of all vertices aligned on the sphere.
    % Coord is a L x d matrix
    % L denotes the number of vertices
    % d denotes the the dimension of the coordinates (2 or 3).

    %[azimuth,elevation] = cart2sph(Coord(:,1),Coord(:,2),Coord(:,3));
    %azimuth0=unique(azimuth); elevation0=unique(elevation);
    %azimuth0_sort=sort(azimuth0); elevation0_sort=sort(elevation0);
    %xind=zeros(size(Coord,1),1); yind=zeros(size(Coord,1),1);
    %for ll=1:size(Coord,1)
    %    xind(ll)=find(azimuth0_sort==azimuth(ll));
    %    yind(ll)=find(elevation0_sort==elevation(ll));
    %end
    %new_2D_img=zeros(length(azimuth0),length(elevation0));
    %fprintf('The dimension of 2D image (Cartesian coordinates to spherical) is %i x %i.\n',size(new_2D_img));
    %indd=sub2ind(size(new_2D_img),xind,yind);

    %%

    if strcmp(CovariatesName(end-2:end),'mat')
        temp=load(CovariatesName);
        temp1=whos('-file',CovariatesName);
        design_data=temp.(temp1.name);
    elseif strcmp(CovariatesName(end-2:end),'txt')
        design_data=importdata(CovariatesName);
    else 
        design_data=load(CovariatesName);
    end
    % design_data: the text file containing covariates of interest. Please always include the intercept in the first column.
    % design_data is a n x p matrix
    % n denotes the number of subjects
    % p denotes the number of all covariates.

    %%
    % read the covariates of interest

    if strcmp(CovariateofInterestName(end-2:end),'mat')
        temp=load(CovariateofInterestName);
        temp1=whos('-file',CovariateofInterestName);
        n_Interest=temp.(temp1.name);
    elseif strcmp(CovariateofInterestName(end-2:end),'txt')
        n_Interest=importdata(CovariateofInterestName);
    else
        n_Interest=load(CovariateofInterestName);
    end

    %%

    if strcmp(CovariateTypeName(end-2:end),'mat')
        temp=load(CovariateTypeName);
        temp1=whos('-file',CovariateTypeName);
        n_Con=temp.(temp1.name);
    else
        n_Con=load(CovariateTypeName);
    end

    %%

    fprintf('The output directory is %s .\n',OutputDir);

    %% 
    fprintf('+++++++Construct the design matrix including (1) picking up covariates of interest and (2) normalization+++++++\n');
    Xdesign = stat_read_x(design_data, n_Interest, n_Con);
    fprintf('The dimension of design matrix is %i x %i .\n',size(Xdesign));

    %% 
    fprintf('+++++++Optimal bandwidth selection+++++++\n');
    tic;
    flag=stat_lpks_wob(Coord,Xdesign,Ydesign);
    toc;

    %% 
    fprintf('+++++++Local polynomial kernel smoothing (order = 1) with preselected bandwidth+++++++\n');
    tic;
    [efitBetas,efitYdesign]=stat_lpks_wb1(Coord,Xdesign,Ydesign,flag);
    toc;

    %% 
    fprintf('+++++++Kernel smoothing (order = 1) for smooth functions (eta)+++++++\n');
    ResYdesign=Ydesign-efitYdesign;
    tic;
    [efitEtas,~,eSigEta]=stat_sif(Coord,ResYdesign);
    toc;

    %% 
    fprintf('+++++++Hypothesis testing+++++++\n');
    % hypothesis: beta_pj(d)=0 v.s. beta_pj(d)~=0 for all j and d

    [~, p0]=size(Xdesign);     %   n  = sample size    p  = number of covariates
    [L, ~]=size(Coord);    %   L = number of location of imaging measurement    d  = dimension of corrdinate
    m=size(Ydesign,3);     %   m  = number of features

    Lpvals=zeros(L,p0-1);
    Lpvals_fdr=zeros(L,p0-1);
    Gpvals=zeros(1,p0-1);
    clu_pvals=cell(1,p0-1);
    Lpval_area=cell(1,p0-1);
    GG=500;   % number of bootstrap samples
    thres=2;

    for pp=2:p0 % go through all covariate

        %individual and global statistics calculation
        cdesign=zeros(1,p0);
        cdesign(pp)=1;
        [Gstat,Lstat] = stat_ht_wald(Xdesign,efitBetas,eSigEta,cdesign);
        Lpval=1-chi2cdf(Lstat,m);
        [~,~,Lpval_fdr]=stat_fdr(Lpval);
        indd_thres=-log10(Lpval)>=thres;
        if sum(indd_thres)<=10
            Lpval_area{1,pp-1}=[sum(indd_thres)];
        else
            Coord_thres=Coord(indd_thres,:);
            clust = zeros(size(Coord_thres,1),4);
            for i=1:4
                clust(:,i) = kmeans(Coord_thres,i,'emptyaction','singleton','replicate',5);
            end
            eva=evalclusters(Coord_thres,clust,'CalinskiHarabasz');
            label=clust(:,eva.OptimalK);
            areas=zeros(1,eva.OptimalK);
            for k=1:eva.OptimalK
                areas(k)=sum(label==k);
            end
            Lpval_area{1,pp-1}=areas;
        end
        Lpvals(:,pp-1)=Lpval;
        Lpvals_fdr(:,pp-1)=Lpval_fdr;

        % Generate random samples and calculate the corresponding statistics and pvalues
        [Gpval,clu_pval] = stat_bstrp_pvalue(Coord,Xdesign,Ydesign,cdesign,Gstat,flag,GG,thres,areas);
        Gpvals(1,pp-1)=Gpval;
        clu_pvals{1,pp-1}=clu_pval;

    end

    toc

    %%
    fprintf('+++++++Save all the results+++++++\n');
    str=fullfile(OutputDir,'efit.mat');
    save(str,'efitYdesign','efitBetas','efitEtas')

    str=fullfile(OutputDir,'pvalues.mat');
    save(str,'Gpvals','Lpvals_fdr','Lpval_area','clu_pvals')

    fprintf('+++++++Your job is finished!!+++++++\n');
    
    outputFiles = {fullfile(OutputDir,'efit.mat') fullfile(OutputDir,'pvalues.mat')};
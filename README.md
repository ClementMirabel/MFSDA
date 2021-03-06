# MFSDA (Multivariate Functional Shape Data Analysis)

This MFSDA package is developed by Chao Huang and Hongtu Zhu from the [BIG-S2 lab](http://odin.mdacc.tmc.edu/bigs2/). 

Multivariate Functional Shape Data Analysis (MFSDA) is a Matlab based package for statistical shape analysis. A multivariate varying coefficient model is introduced to build the association between the multivariate shape measurements and demographic information and other clinical variables. Statistical inference, i.e., hypothesis testing, is also included in this package, which can be used in investigating whether some covariates of interest are significantly associated with the shape information. The hypothesis testing results are further used in clustering based analysis, i.e., significant suregion detection. 

# GUI Interface
This toolbox is written in a user-friendly GUI interface. Here are some explainations of the interface:

1. Load raw data

In this panel, you need to select (a). the folder where coordinate data (template file, vtk format) is stored; (b). the file containing the covariate matrix (could be either txt format or mat format); (c). the file indicating which covariates you are interested in the statistical analysis (could be either txt format or mat format); (d). the file indicating which covariates are continuous (1 is continuous and 0 otherwise, could be either txt format or mat format); (e). the folder where shape dataset (vtk format) is stored

2. Clear & Run

In this panel, you need to select the folder where to save all  the output files. The 'Clear' button help you to clear all the preselcted input information, and the 'Run' button is clicked when all the input information is selected and the analysis is ready to go.

3. Export Results

In this panel, you can plot the results you are interested in. 

4. Export results in JSON format

Please download the package JSON lab to export the resulting mat files to JSON format.

Home page for JSONlab

https://www.mathworks.com/matlabcentral/fileexchange/33381-jsonlab--a-toolbox-to-encode-decode-json-files

Download link for version 1.5

https://www.mathworks.com/matlabcentral/mlc-downloads/downloads/submissions/33381/versions/22/download/zip

Extract the toolbox in the root directory of the MFSDA app, the directory must be named 'jsonlab-1.5'. 


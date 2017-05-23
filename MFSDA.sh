#!/bin/bash

function help
{
        echo "Executes the MFSDA application for shape analysis"
        echo $0 
        echo "Options: "
        echo "-shapeData <filename, .txt list with vtk filenames, 1 file per line>"
        echo "-coordData <filename, .vtk shape template>"
        echo "-covariates <filename, .txt with covariates dim = n x p0 (comma separated or tabulation, without header, the first column is the group)>"
        echo "-covariateInterest <filename, .txt (dim = 1xp0 vector comma separated, 1 or 0 value to indicate covariate of interest)>"
        echo "-covariateType <filename, .txt (dim= 1xsum(covariateInterest) vector comma separated, 1 or 0 to indicate type of covariate double or int)>"
        echo "-outputDir <output directory>"
        exit 
}

shapeData=""
coordData=""
covariates=""
covariateInterest=""
covariateType=""
outputDir="./out"

previous=""
for var in "$@"
do
        if [ "$previous" == "-shapeData" ];
        then
                shapeData=$var
        fi

        if [ "$previous" == "-coordData" ];
        then
                coordData=$var
        fi

        if [ "$previous" == "-covariates" ];
        then
                covariates=$var
        fi

        if [ "$previous" == "-covariateInterest" ];
        then
                covariateInterest=$var
        fi

        if [ "$previous" == "-covariateType" ];
        then
                covariateType=$var
        fi

        if [ "$previous" == "-outputDir" ];
        then
                outputDir=$var
        fi
        
        if [ "$var" == "-h" ] || [ "$var" == "--help" ];
        then
                help
        fi

        previous=$var
done

if [ "$shapeData" == "" ] || [ "$coordData" == "" ] || [ "$covariates" == "" ] || [ "$covariateInterest" == "" ] || [ "$covariateType" == "" ];
then
        help
fi

echo "Using the following values: type -h or --help for options"
echo "shapeData=$shapeData"
echo "coordData=$coordData"
echo "covariates=$covariates"
echo "covariateInterest=$covariateInterest"
echo "covariateType=$covariateType"
echo "outputDir=$outputDir"

if [ ! -d $outputDir ];
then
        mkdir -p $outputDir
fi

if [ -e /tools/bin_linux64/matlab2012 ];
then
	matlab_app=/tools/bin_linux64/matlab2012
else

	matlab_app=$(which matlab)
	if [ ! -f $matlab_app ];
	then
		echo "No matlab executable found. Please add matlab to your environment in PATH"
		exit
	fi

fi


echo "Using matlab at $matlab_app"
scriptname=$(basename $0)
scriptdir=${BASH_SOURCE[0]}
scriptdir=${scriptdir/$scriptname/}

command="$matlab_app -nodisplay -r \"addpath('\"$scriptdir\"');MFSDA_CMD('\"$shapeData\"','\"$coordData\"','\"$covariates\"','\"$covariateInterest\"','\"$covariateType\"','\"$outputDir\"');\""
echo $command
eval $command

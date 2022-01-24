%{
Purdue Space Program - Liquids
Rocket 3 ECP2 - Throttling
-----------------------------------------
Contributors: Liam Schenk
Last Modified: 22 Jan., 2022
Description: Script for Rocket 3 throttling models.
Version: v1.1.1
%}
clear;
clc;

% Distribute Results
mainPath = cd;
dirExist = exist("ECP2.Output","dir");
while dirExist ~= 7
    mkdir ECP2.Output
    dirExist = exist("ECP2.Output","dir");
end
cd ..\ECP\ECP2.Output
outputPath = cd;
cd(mainPath)
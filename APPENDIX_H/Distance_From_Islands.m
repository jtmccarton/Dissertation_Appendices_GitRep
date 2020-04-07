%% measure distance from easternnmost island coordinates to eddy centre
clear all;

ddir = 'YOUR DIRECTORY TO FORMATION DATA FILES HERE';
addpath(genpath('/Applications/m_map'))

myDataFile = 'EddyData.csv';
%myDataFile = 'FilamentData.csv';

inFile = [ddir myDataFile];
formData = readtable(inFile);

JD = formData.JD;
formLat = formData.E_centerlat;
formLon = formData.E_centerlon;
%formLat = formData.T1centerlat;
%formLon = formData.T1centerlon;
isLat = formData.east_lat;
isLon = formData.east_lon;


for k = 1:length(formLat)
    myformLat = formLat(k,1);
    myformLon = formLon(k,1);
    myisLat = isLat(k,1);
    myisLon = isLon(k,1);
    myJD = JD(k,1);
    
    
    Dist = m_lldist([myisLon, myformLon], [myisLat, myformLat], 'km');
    
    clear outputarray
    output = [myJD; Dist].'; 
    dlmwrite('EddyDistAppend.csv', output, '-append', 'delimiter',',', 'roffset', 0, 'coffset', 0);
end

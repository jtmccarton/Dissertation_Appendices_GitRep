% parse in situ profiles to pull out lat, lon, year, month, day and surface
% 10 m of chl from in situ data files.
% function [lat,lon,yy,mm,dd,hh,chl10] = profileread(filepath)
% filepath is the absolute file path including file name
%
% VARIABLES 	Depth     	F	O	Temperatur 	F	O	Salinity   	F	O	Oxygen     	F	O	Nitrate    	F	O	Chlorophyl 	F	O	Pressure   	F	O						
% UNITS     	m         	 	 	degrees C 		 	 	PSS       		 	 	umol/kg   		 	 	umol/kg   		 	 	ug/l      		 	 	dbar      		 	 
% Prof-Flag 	          	0	 	          	0	 	          	0	 	          	9	 	          	0	 	          	0	 	          	0	 						
% 1	0	0	1	   ---0---	0	1	   ---0---	0	1	186.606	0	1	   ---0---	0	1	0.248	0	1	0	0	1						
% 2	0.1	0	1	   ---0---	0	1	   ---0---	0	1	190.61	0	1	   ---0---	0	1	0.248	0	1	0.1	0	1						
function [lat,lon,dt,chl10,Nsamp] = profilereadnew(filepath,chl_col)

fid = fopen(filepath,'r');

% skip to latitude
for i=1:4
    fgets(fid);
end

fmt = repmat('%s ',1,28);
% get latitude line:
nextline = fgets(fid);
column_vals = textscan(nextline,fmt,'delimiter',',');
lat = str2double(column_vals{3});

% get longitude line:
nextline = fgets(fid);
column_vals = textscan(nextline,fmt,'delimiter',',');
lon = str2double(column_vals{3});

% get year:
nextline = fgets(fid);
column_vals = textscan(nextline,fmt,'delimiter',',');
yy = str2double(column_vals{3});

% get month:
nextline = fgets(fid);
column_vals = textscan(nextline,fmt,'delimiter',',');
MM = str2double(column_vals{3});

% get day
nextline = fgets(fid);
column_vals = textscan(nextline,fmt,'delimiter',',');
dd = str2double(column_vals{3});

% get decimal hours
nextline = fgets(fid);
column_vals = textscan(nextline,fmt,'delimiter',',');
decimal_hr = str2double(column_vals{3});
hh = floor(decimal_hr); %extract integer hour ftom decimal hour
mm = floor( (decimal_hr-hh) * 60); %extract integer minute from decimal hour

% create matlab datetime object type for date and time of cast
dt = datetime(yy,MM,dd,hh,mm,00);

% skip rest of header:
for i=1:19
    fgets(fid);
end

% get upper 10 m chl:
allchl = nan;
counter = 0;
while (~feof(fid))
     nextline = fgets(fid);
     column_vals = textscan(nextline,fmt,'delimiter',',');
     tmp2 = cell2mat(column_vals{chl_col}); % which may be a missing string '---0---' or else numeric
     if ~strcmp(tmp2, '--0--')
         counter = counter+1;
         allchl(counter) = str2double(tmp2);
     end
end
chl10 = nanmean(allchl);
Nsamp = length(allchl);

fclose(fid);
return;







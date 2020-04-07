Suggested edits here

% MATCH UPS

clear variables;

addpath(genpath('YOUR DIRECTORY TO SCRIPT HERE'))

dx = 0.003; % lon res @ 30.5°N
dy = 0.0027; % lat res
lon1 = 125; lon2 = 135; lat1 = 25; lat2 = 30.5; % define ROI
lonspace = [lon1 : dx : lon2]; % define lon axis spacing/grid
latspace = [lat1 : dy : lat2]; % define lat axis spacing/grid
[mylat, mylon] = meshgrid(lonspace, latspace); % define grid array (??)

[NN_bit_mask, OC4_bit_mask] = getbitmasks();

%% dir list for ship and cast data
argopath='YOUR DIRECTORY TO ARGO FOLDER HERE';
cd(argopath);
csvFiles = dir('*.csv');

%% dir list for satellite
% look for files ending in .mat
satpath='YOUR DIRECTORY TO REGRIDDED OLCI DATA HERE';
cd(satpath);
matFiles = dir('*.mat');

mc = 0; % matchcounter
    
for k = 1:length(matFiles)
    disp(['Processing ' matFiles(k).name '...']);
    basematFileName = matFiles(k).name;
    fullmatFileName = [satpath basematFileName];
    % load all mat file contents into struct sat_data
    sat_data = load(fullmatFileName);
    
    %% MAKE FLAG MASKS
    
    %%this is the operation you want to NaN the pixels that match any of your
    %%flag conditions
    sat_data.ChlNN2(find(bitand(sat_data.myWQSF2,NN_bit_mask)))=NaN;
    sat_data.ChlOC42(find(bitand(sat_data.myWQSF2,OC4_bit_mask)))=NaN;
    
    % and create variables for yy mm dd
    % example file name S3A_20190304T010226.mat
    
    satYear = str2double(basematFileName(5:8));
    satMonth = str2double(basematFileName(9:10));
    satDay = str2double(basematFileName(11:12));
    satHour = str2double(basematFileName(14:15));
    satMin = str2double(basematFileName(16:17));
    satSec = str2double(basematFileName(18:19));
    
    satDT = datetime(satYear, satMonth, satDay, satHour, satMin, satSec);

    for k2 = 1:length(csvFiles)
        basecsvFileName = csvFiles(k2).name;
        fullcsvFileName = [argopath basecsvFileName];
        % fullcsvFileName = fullfile(argofolder2, basecsvFileName);
        % pass column number as 2nd arg: 17 for CN_947, 14 for CN_949
        [lat,lon,castDT,chl10,Nsamp] = profilereadnew(fullcsvFileName,14);
        
        % find if that yy, mm, dd in satellite list exists (time +/- 24hrs??)
        time_diff = hours(satDT-castDT);
%         disp({satDT castDT time_diff});
        if abs(time_diff) < 72
            
            % locate pixel in satellite data
            
            thislon = ceil((lon - lonspace(1)) / dx); %thislon is longitude pixel number, dy is spacing
            thislat = ceil((lat - latspace(1)) / dy);
            
            if thislon > 0 && thislon <= length(lonspace) && thislat > 0 && thislat <= length(latspace)
                disp(['Location match found in ' csvFiles(k2).name '!']);                
                %if you want, pull out 3x3 box of pixels and take
                %median of
                clear tmpNN; clear tmpOC4;
                tmpNN = nanmedian(sat_data.ChlNN2(thislon - 1:thislon + 1, thislat - 1:thislat + 1),'all');
                tmpOC4 = nanmedian(sat_data.ChlOC42(thislon-1:thislon+1, thislat-1:thislat+1),'all');
                if ~(isnan(tmpNN) && isnan(tmpOC4))
                    mc = mc+1;
                    disp(['Match ' num2str(mc) ' is good: ChlNN=' num2str(tmpNN) '; ChlOC4=' num2str(tmpOC4)]);

                    matchNNChlAVG(mc) = tmpNN;
                    matchOC4ChlAVG(mc) = tmpOC4;                

                    matchlon(mc) = lon;
                    matchlat(mc) = lat;
                    matchchlArgo(mc) = chl10;
                    matchArgoN(mc) = Nsamp;
                    matchyear(mc) = year(castDT);
                    matchmonth(mc) = month(castDT);
                    matchday(mc) = day(castDT);
                    matchtimediff(mc) = time_diff;
                    matchNNChl(mc) = sat_data.ChlNN2(thislon,thislat);
                    matchOC4Chl(mc) = sat_data.ChlOC42(thislon,thislat);
      
                else
                    disp('Phooey - NaNs!'); 
                end
                
                
            end
        end
    end
end


% store chlorophyll value in new table
% AFTER ALL LOOPS
outfile = 'Sat_InSitu_Matchups.txt';
fid = fopen(outfile,'a'); % append is 'a', write is 'w'
outputarray = [matchlon; matchlat; matchyear; matchmonth; matchday;...
    matchtimediff; matchchlArgo; matchArgoN; matchNNChl; matchOC4Chl;...
    matchNNChlAVG; matchOC4ChlAVG]; % CHECK DIMENSION
% help fprintf
fprintf(fid, 'argo, %7.4f, %7.4f, %d, %d, %d, %f, %f, %d, %f, %f, %f, %f\n', outputarray); %f is the number of things in the table
fclose(fid); % test size of output array and check that all comes out correctly
















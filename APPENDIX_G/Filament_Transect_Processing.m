% PROCESS SEAMOUNT TRANSECT DATA
% Filament data: 3 transects along filament (T1, T2, T3)

% JUST LOG EVERYTHING AT THE END

clear all

ddir = 'YOUR DIRECTORY TO TRANSECT FILES HERE';
cd(ddir)
addpath(genpath('/Applications/m_map')) % to use m_lldist for cumdist
% index filament files
filamentFiles = dir('F*.csv');
T1count = 0; % try to count how many transects??
T2count = 0;
T3count = 0;

% loop through filament files
k = 148

while k <= 165
      baseFileName = filamentFiles(k).name; 
      formation = baseFileName(1:1); % extract first letter (E, F or S)
      
      
      % determine if horizontal transect
      %if strfind(baseFileName, 'Horiz') > 1
          T1count = T1count + 1; % this is +1 horizontal transects
          disp('TRANSECT 1, Filament')
          disp(T1count)
          
          T1breaklocation = strfind(baseFileName,'T'); % horiz?
          T1transectNum = baseFileName(2:T1breaklocation-1); % extract num
          T1transectNum = str2double(T1transectNum);
         
          
          % read profile
          T1Profile = csvread(baseFileName, 1, 0);
          T1lats = T1Profile(:,4);
          T1lons = T1Profile(:,5);
          T1pixelnum = T1Profile(:,1);
          T1dist = m_lldist([T1lons], [T1lats], 'km');
          T1cumdist = cumsum(T1dist); % cumulative distance (km)
          T1chl = T1Profile(:, 6);
          T1stdev = T1Profile(:,7);
          T1chlavg = 0.5 * (T1chl(1:end-1) + T1chl(2:end));
          T1logchl = log10(T1chl);
          
          % plot chl / pixel 
          % RECORD CLASS INFO FOR EACH IN SPREADSHEET!!! (A, B, C, P)
          clear fig
          clear figure1
          figure1 = figure;
          plot(T1pixelnum, T1chl) 
          title(baseFileName)
          % select center and boundaries of transect
          hold on
          T1pts = ginput(4);
          % choose 4 points for the cases with 2 peaks
          % if one peak, choose the same point twice
          % then average 2 peak values later
        
          % name values from selection
          T1bound1pixel = round(T1pts(1,1));
          T1bound1chl = T1Profile(T1bound1pixel,6);
          T1center1pixel = round(T1pts(2,1));
          T1center1chl = T1Profile(T1center1pixel,6);
          T1center2pixel = round(T1pts(3,1));
          T1center2chl = T1Profile(T1center2pixel,6);
          T1bound2pixel = round(T1pts(4,1));
          T1bound2chl = T1Profile(T1bound2pixel,6);
          
          % record center lat and lon
          T1index1 = find(T1Profile(:,1) == T1center1pixel)
          T1index2 = find(T1Profile(:,1) == T1center2pixel)
          T1indexcenter = round((T1index1 + T1index2)/2);
          
          T1center1lat = T1Profile(T1index1, 4);
          T1center1lon = T1Profile(T1index1, 5);
          T1center2lat = T1Profile(T1index2, 4);
          T1center2lon = T1Profile(T1index2, 5);
          % get average center of filament 1 peaks
          T1centerlat_avg = (T1center1lat + T1center2lat)/2;
          T1centerlon_avg = (T1center1lon + T1center2lon)/2;
          
          % find where profile crosses 1/2 average of bound chl values
          T1baselinechl = (T1bound1chl + T1bound2chl)/2; % average of bounds = baseline
          T1centerchl = (T1center1chl + T1center2chl)/2; % average the center chlorophylls
                                % if its the same point it won't matter
                                % only one or two transects, of an
                                % occasional filament, have 2 peaks
          
          T1amplitudechl = T1centerchl - T1baselinechl; % amplitude of chl
          T1halfampchl = T1amplitudechl/2; % value at half of amplitude 
          T1halfmaxchl = T1centerchl - T1halfampchl; % chl value at half max
          
          % interpolate between lat, lon and chl values in matrix
          % in order to then get exact distance at half max
          T1x = T1cumdist;
          T1y = T1chlavg;
          T1x_fine = linspace(T1cumdist(1,1),T1cumdist(end),100);
          [T1x, T1index] = unique(T1x);
          Hy_fine = interp1(T1x, T1chlavg(T1index), T1x_fine);
          clear figure
          figure2 = figure;
          plot(T1cumdist, T1chlavg, 'ro', T1x_fine, Hy_fine, ':.')
          
          % find full width half max (km)
          clear T1interpmatrix
          clear T1halfinterpmatrix
          T1interpmatrix = [T1x_fine(:), Hy_fine(:)];% create matrix of interpolated values
          T1halfinterpmatrix = T1interpmatrix(T1interpmatrix(:,2) >= T1halfmaxchl, :);% isolate upper half of profile
          T1first_halfmaxdist = T1halfinterpmatrix(1,1);    % first value
          T1last_halfmaxdist = T1halfinterpmatrix(end,1);   %last value
          
          T1_FWHM = T1last_halfmaxdist - T1first_halfmaxdist;
          
          % find gradient to left and right of center & STDEV
          T1first_diff = T1centerchl - T1bound1chl; % difference between center chl and left bound
          T1index3 = find(T1Profile(:,1) == T1bound1pixel); % location of bound1
          % this is creating a problem because it is finding two locations
          % change to using pixel instead of chlorophyll
          T1bound1_stdev = T1Profile(T1index3, 7); % bound1 stdev stdev
          T1bound1dist = T1cumdist(T1index3); % cumulative distance @ bound1
          % Hfirst_diff_stdev = (Hbound1_stdev + HcenterSTDEV)/2;

          T1last_diff = T1centerchl - T1bound2chl; % difference between center chl and right bound
          T1index4 = find(T1Profile(:,1) == T1bound2pixel); % location of bound2
          T1bound2_stdev = T1Profile(T1index4, 7); % bound2 chl stdev
          %Hlast_diff_stdev = (Hbound2_stdev + HcenterSTDEV)/2;
          T1boundsSTDEV = (T1bound2_stdev + T1bound1_stdev)/2;
          
          T1center_dist = T1cumdist(T1indexcenter); % cumulative distance @ center
          T1center1STDEV = T1Profile(T1index1, 7); % chl stdev @ center
          T1center2STDEV = T1Profile(T1index2, 7);
          T1centerSTDEV = (T1center1STDEV + T1center2STDEV)/2;
          T1bound2dist = T1cumdist(T1index4); % cumulative distance @ bound2
          
          T1first_dist = T1center_dist - T1bound1dist; % distance btw centre and bound1
          T1last_dist = T1bound2dist - T1center_dist; % distance btw centre and bound2
          
          T1first_gradient = T1first_diff / T1first_dist; % center --> bound1 gradient
          T1last_gradient = T1last_diff / T1last_dist; % center --> bound1 gradient
          
          % find average gradient for horizontal
          T1avg_gradient = (T1first_gradient + T1last_gradient)/2;
          %avg_gradient_logged = ((log10(first_diff)/first_dist) + (log10(first_diff)/last_dist))/2
          T1avg_gradient_logged_last = log10(T1avg_gradient);
          
          close(figure1)
          close(figure2)
    
          
          
          
          %###################
          
          
          
          
      % for Transect 2:
      k = k + 1;
          baseFileName = filamentFiles(k).name; 
          formation = baseFileName(1:1); % extract first letter (E, F or S)

      
      % determine if horizontal transect
      %if strfind(baseFileName, 'Horiz') > 1
          T2count = T2count + 1; % this is +1 horizontal transects
          disp('TRANSECT 2, Filament')
          disp(T2count)
          
          T2breaklocation = strfind(baseFileName,'T'); % horiz?
          T2transectNum = baseFileName(2:T2breaklocation-1); % extract num
          T2transectNum = str2double(T2transectNum);
         
          
          % read profile
          T2Profile = csvread(baseFileName, 1, 0);
          T2lats = T2Profile(:,4);
          T2lons = T2Profile(:,5);
          T2pixelnum = T2Profile(:,1);
          T2dist = m_lldist([T2lons], [T2lats], 'km');
          T2cumdist = cumsum(T2dist); % cumulative distance (km)
          T2chl = T2Profile(:, 6);
          T2stdev = T2Profile(:,7);
          T2chlavg = 0.5 * (T2chl(1:end-1) + T2chl(2:end));
          T2logchl = log10(T2chl);
          
          % plot chl / pixel 
          % RECORD CLASS INFO FOR EACH IN SPREADSHEET!!! (A, B, C, P)
          clear fig
          clear figure1
          figure1 = figure;
          plot(T2pixelnum, T2chl) 
          title(baseFileName)
          % select center and boundaries of transect
          hold on
          T2pts = ginput(4);
          % choose 4 points for the cases with 2 peaks
          % if one peak, choose the same point twice
          % then average 2 peak values later
        
          % name values from selection
          T2bound1pixel = round(T2pts(1,1));
          T2bound1chl = T2Profile(T2bound1pixel,6);
          T2center1pixel = round(T2pts(2,1));
          T2center1chl = T2Profile(T2center1pixel,6);
          T2center2pixel = round(T2pts(3,1));
          T2center2chl = T2Profile(T2center2pixel,6);
          T2bound2pixel = round(T2pts(4,1));
          T2bound2chl = T2Profile(T2bound2pixel,6);
          
          % record center lat and lon
          T2index1 = find(T2Profile(:,1) == T2center1pixel)
          T2index2 = find(T2Profile(:,1) == T2center2pixel)
          T2indexcenter = round((T2index1 + T2index2)/2);
          
          T2center1lat = T2Profile(T2index1, 4);
          T2center1lon = T2Profile(T2index1, 5);
          T2center2lat = T2Profile(T2index2, 4);
          T2center2lon = T2Profile(T2index2, 5);
          % get average center of filament 1 peaks
          T2centerlat_avg = (T2center1lat + T2center2lat)/2;
          T2centerlon_avg = (T2center1lon + T2center2lon)/2;
          
          % find where profile crosses 1/2 average of bound chl values
          T2baselinechl = (T2bound1chl + T2bound2chl)/2; % average of bounds = baseline
          T2centerchl = (T2center1chl + T2center2chl)/2; % average the center chlorophylls
                                % if its the same point it won't matter
                                % only one or two transects, of an
                                % occasional filament, have 2 peaks
          
          T2amplitudechl = T2centerchl - T2baselinechl; % amplitude of chl
          T2halfampchl = T2amplitudechl/2; % value at half of amplitude 
          T2halfmaxchl = T2centerchl - T2halfampchl; % chl value at half max
          
          % interpolate between lat, lon and chl values in matrix
          % in order to then get exact distance at half max
          T2x = T2cumdist;
          T2y = T2chlavg;
          T2x_fine = linspace(T2cumdist(1,1),T2cumdist(end),100);
          [T2x, T2index] = unique(T2x);
          Hy_fine = interp1(T2x, T2chlavg(T2index), T2x_fine);
          clear figure
          figure2 = figure;
          plot(T2cumdist, T2chlavg, 'ro', T2x_fine, Hy_fine, ':.')
          
          % find full width half max (km)
          clear T2interpmatrix
          clear T2halfinterpmatrix
          T2interpmatrix = [T2x_fine(:), Hy_fine(:)];% create matrix of interpolated values
          T2halfinterpmatrix = T2interpmatrix(T2interpmatrix(:,2) >= T2halfmaxchl, :);% isolate upper half of profile
          T2first_halfmaxdist = T2halfinterpmatrix(1,1);    % first value
          T2last_halfmaxdist = T2halfinterpmatrix(end,1);   %last value
          
          T2_FWHM = T2last_halfmaxdist - T2first_halfmaxdist;
          
          % find gradient to left and right of center & STDEV
          T2first_diff = T2centerchl - T2bound1chl; % difference between center chl and left bound
          T2index3 = find(T2Profile(:,1) == T2bound1pixel); % location of bound1
          % this is creating a problem because it is finding two locations
          % change to using pixel instead of chlorophyll
          T2bound1_stdev = T2Profile(T2index3, 7); % bound1 stdev stdev
          T2bound1dist = T2cumdist(T2index3); % cumulative distance @ bound1
          % Hfirst_diff_stdev = (Hbound1_stdev + HcenterSTDEV)/2;

          T2last_diff = T2centerchl - T2bound2chl; % difference between center chl and right bound
          T2index4 = find(T2Profile(:,1) == T2bound2pixel); % location of bound2
          T2bound2_stdev = T2Profile(T2index4, 7); % bound2 chl stdev
          %Hlast_diff_stdev = (Hbound2_stdev + HcenterSTDEV)/2;
          T2boundsSTDEV = (T2bound2_stdev + T2bound1_stdev)/2;
          
          T2center_dist = T2cumdist(T2indexcenter); % cumulative distance @ center
          T2center1STDEV = T2Profile(T2index1, 7); % chl stdev @ center
          T2center2STDEV = T2Profile(T2index2, 7);
          T2centerSTDEV = (T2center1STDEV + T2center2STDEV)/2;
          T2bound2dist = T2cumdist(T2index4); % cumulative distance @ bound2
          
          T2first_dist = T2center_dist - T2bound1dist; % distance btw centre and bound1
          T2last_dist = T2bound2dist - T2center_dist; % distance btw centre and bound2
          
          T2first_gradient = T2first_diff / T2first_dist; % center --> bound1 gradient
          T2last_gradient = T2last_diff / T2last_dist; % center --> bound1 gradient
          
          % find average gradient for horizontal
          T2avg_gradient = (T2first_gradient + T2last_gradient)/2;
          %avg_gradient_logged = ((log10(first_diff)/first_dist) + (log10(first_diff)/last_dist))/2
          T2avg_gradient_logged_last = log10(T2avg_gradient);
          
          close(figure1)
          close(figure2)
          
          
          
          
          %###################
          
          
          
          
          k = k + 1;
           baseFileName = filamentFiles(k).name; 
           formation = baseFileName(1:1); 

           % determine if horizontal transect
      %if strfind(baseFileName, 'Horiz') > 1
          T3count = T3count + 1; % this is +1 horizontal transects
          disp('TRANSECT 3, Filament')
          disp(T3count)
          
          T3breaklocation = strfind(baseFileName,'T'); % horiz?
          T3transectNum = baseFileName(2:T3breaklocation-1); % extract num
          T3transectNum = str2double(T3transectNum);
         
          
          % read profile
          T3Profile = csvread(baseFileName, 1, 0);
          T3lats = T3Profile(:,4);
          T3lons = T3Profile(:,5);
          T3pixelnum = T3Profile(:,1);
          T3dist = m_lldist([T3lons], [T3lats], 'km');
          T3cumdist = cumsum(T3dist); % cumulative distance (km)
          T3chl = T3Profile(:, 6);
          T3stdev = T3Profile(:,7);
          T3chlavg = 0.5 * (T3chl(1:end-1) + T3chl(2:end));
          T3logchl = log10(T3chl);
          
          % plot chl / pixel 
          % RECORD CLASS INFO FOR EACH IN SPREADSHEET!!! (A, B, C, P)
          clear fig
          clear figure1
          figure1 = figure;
          plot(T3pixelnum, T3chl) 
          title(baseFileName)
          % select center and boundaries of transect
          hold on
          T3pts = ginput(4);
          % choose 4 points for the cases with 2 peaks
          % if one peak, choose the same point twice
          % then average 2 peak values later
        
          % name values from selection
          T3bound1pixel = round(T3pts(1,1));
          T3bound1chl = T3Profile(T3bound1pixel,6);
          T3center1pixel = round(T3pts(2,1));
          T3center1chl = T3Profile(T3center1pixel,6);
          T3center2pixel = round(T3pts(3,1));
          T3center2chl = T3Profile(T3center2pixel,6);
          T3bound2pixel = round(T3pts(4,1));
          T3bound2chl = T3Profile(T3bound2pixel,6);
          
          % record center lat and lon
          T3index1 = find(T3Profile(:,1) == T3center1pixel)
          T3index2 = find(T3Profile(:,1) == T3center2pixel)
          T3indexcenter = round((T3index1 + T3index2)/2);
          
          T3center1lat = T3Profile(T3index1, 4);
          T3center1lon = T3Profile(T3index1, 5);
          T3center2lat = T3Profile(T3index2, 4);
          T3center2lon = T3Profile(T3index2, 5);
          % get average center of filament 1 peaks
          T3centerlat_avg = (T3center1lat + T3center2lat)/2;
          T3centerlon_avg = (T3center1lon + T3center2lon)/2;
          
          % find where profile crosses 1/2 average of bound chl values
          T3baselinechl = (T3bound1chl + T3bound2chl)/2; % average of bounds = baseline
          T3centerchl = (T3center1chl + T3center2chl)/2; % average the center chlorophylls
                                % if its the same point it won't matter
                                % only one or two transects, of an
                                % occasional filament, have 2 peaks
          
          T3amplitudechl = T3centerchl - T3baselinechl; % amplitude of chl
          T3halfampchl = T3amplitudechl/2; % value at half of amplitude 
          T3halfmaxchl = T3centerchl - T3halfampchl; % chl value at half max
          
          % interpolate between lat, lon and chl values in matrix
          % in order to then get exact distance at half max
          T3x = T3cumdist;
          T3y = T3chlavg;
          T3x_fine = linspace(T3cumdist(1,1),T3cumdist(end),100);
          [T3x, T3index] = unique(T3x);
          Hy_fine = interp1(T3x, T3chlavg(T3index), T3x_fine);
          clear figure
          figure2 = figure;
          plot(T3cumdist, T3chlavg, 'ro', T3x_fine, Hy_fine, ':.')
          
          % find full width half max (km)
          clear T3interpmatrix
          clear T3halfinterpmatrix
          T3interpmatrix = [T3x_fine(:), Hy_fine(:)];% create matrix of interpolated values
          T3halfinterpmatrix = T3interpmatrix(T3interpmatrix(:,2) >= T3halfmaxchl, :);% isolate upper half of profile
          T3first_halfmaxdist = T3halfinterpmatrix(1,1);    % first value
          T3last_halfmaxdist = T3halfinterpmatrix(end,1);   %last value
          
          T3_FWHM = T3last_halfmaxdist - T3first_halfmaxdist;
          
          % find gradient to left and right of center & STDEV
          T3first_diff = T3centerchl - T3bound1chl; % difference between center chl and left bound
          T3index3 = find(T3Profile(:,1) == T3bound1pixel); % location of bound1
          % this is creating a problem because it is finding two locations
          % change to using pixel instead of chlorophyll
          T3bound1_stdev = T3Profile(T3index3, 7); % bound1 stdev stdev
          T3bound1dist = T3cumdist(T3index3); % cumulative distance @ bound1
          % Hfirst_diff_stdev = (Hbound1_stdev + HcenterSTDEV)/2;

          T3last_diff = T3centerchl - T3bound2chl; % difference between center chl and right bound
          T3index4 = find(T3Profile(:,1) == T3bound2pixel); % location of bound2
          T3bound2_stdev = T3Profile(T3index4, 7); % bound2 chl stdev
          %Hlast_diff_stdev = (Hbound2_stdev + HcenterSTDEV)/2;
          T3boundsSTDEV = (T3bound2_stdev + T3bound1_stdev)/2
        
          T3center_dist = T3cumdist(T3indexcenter); % cumulative distance @ center
          T3center1STDEV = T3Profile(T3index1, 7); % chl stdev @ center
          T3center2STDEV = T3Profile(T3index2, 7);
          T3centerSTDEV = (T3center1STDEV + T3center2STDEV)/2;
          T3bound2dist = T3cumdist(T3index4); % cumulative distance @ bound2
          
          T3first_dist = T3center_dist - T3bound1dist; % distance btw centre and bound1
          T3last_dist = T3bound2dist - T3center_dist; % distance btw centre and bound2
          
          T3first_gradient = T3first_diff / T3first_dist; % center --> bound1 gradient
          T3last_gradient = T3last_diff / T3last_dist; % center --> bound1 gradient
          
          % find average gradient for horizontal
          T3avg_gradient = (T3first_gradient + T3last_gradient)/2;
          %avg_gradient_logged = ((log10(first_diff)/first_dist) + (log10(first_diff)/last_dist))/2
          T3avg_gradient_logged_last = log10(T3avg_gradient);
          
          close(figure1)
          close(figure2)
          
          
      %% average for all 3 transects (all data for specified eddy(k))
     
          clear Eddy_gradient
          clear FWHM
          clear E_centerlat
          clear E_centerlon
          clear Absolute_center_chl
          clear Center_chl_stdev
          clear Absolute_Boundary_chl
          clear Bounds_chl_stdev
          
          Filament_gradient = log10((T1avg_gradient + T2avg_gradient + T3avg_gradient)/3); % average gradient for transects 1,2,3
          FWHM = (T1_FWHM + T2_FWHM + T3_FWHM)/3; % average t-1,2, and 3 FWHM in km
          
          Absolute_center_chl = log10((T1centerchl + T1centerchl + T3centerchl)/3); % logged center chl
          Center_chl_stdev = log10((T1centerSTDEV + T2centerSTDEV + T3centerSTDEV)/3); % logged center chl stdev
          
          Absolute_boundary_chl = log10((T1baselinechl + T2baselinechl + T3baselinechl)/3); % logged boundary chl
          Bounds_chl_stdev = log10((T1boundsSTDEV + T2boundsSTDEV + T2boundsSTDEV)/3); % logged boundary chl stdev
     % else
      %    disp('no match')
      %end


    %% WRITE DATA TO EXISTING FILE
   % C = exist ('Eddy_gradient')
    %if C >= 1
    
    clear outputarray

    ddir2 = 'YOUR OUTPUT DIRECTORY HERE';
    cd(ddir2)

    outputarray = [T1transectNum; Filament_gradient; FWHM; T1centerlat_avg; T1centerlon_avg; Absolute_center_chl;...
        Center_chl_stdev; Absolute_boundary_chl; Bounds_chl_stdev].'; % CHECK DIMENSION 

    dlmwrite('FilamentDataAppend.csv',outputarray,'delimiter',',', '-append')

  %  else
   %     disp('no output')

    %end
    cd(ddir)
    
    k = k + 1;
end

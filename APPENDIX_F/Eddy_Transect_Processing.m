% PROCESS EDDY TRANSECT DATA
% Eddy data: Horizontal and Vertical transects (E1Horiz, E1Vertic, etc)
% Seamount data: Horizontal and Vertical transects (S1Horiz, S1Vertic)
% Filament data: 3 transects (F1T1, F1T2, F1T3)
% JUST LOG EVERYTHING AT THE END

clear all

ddir = 'YOUR DIRECTORY TO TRANSECT FILES HERE';
cd(ddir)
addpath(genpath('/Applications/m_map')) % to use m_lldist for cumdist
% index eddy files
eddyFiles = dir('E*.csv');
Hcount = 0; % try to count how many horiz and vertic transects??
Vcount = 0;

% loop through eddy files
%k=1;
k = 1

while k <= 230
      baseFileName = eddyFiles(k).name; 
      formation = baseFileName(1:1); % extract first letter (E, F or S)

      
      % determine if horizontal transect
      %if strfind(baseFileName, 'Horiz') > 1
          Hcount = Hcount + 1; % this is +1 horizontal transects
          disp('HORIZONTAL TRANSECT NUMBER')
          disp(Vcount)
          
          Hbreaklocation = strfind(baseFileName,'H'); % horiz?
          HtransectNum = baseFileName(2:Hbreaklocation-1); % extract num
          HtransectNum = str2double(HtransectNum);
         
          
          % read profile
          HProfile = csvread(baseFileName, 1, 0);
          Hlats = HProfile(:,4);
          Hlons = HProfile(:,5);
          Hpixelnum = HProfile(:,1);
          Hdist = m_lldist([Hlons], [Hlats], 'km');
          Hcumdist = cumsum(Hdist); % cumulative distance (km)
          Hchl = HProfile(:, 6);
          Hstdev = HProfile(:,7);
          Hchlavg = 0.5 * (Hchl(1:end-1) + Hchl(2:end));
          Hlogchl = log10(Hchl);
          
          % plot chl / pixel 
          % RECORD CLASS INFO FOR EACH IN SPREADSHEET!!! (A, B, C, P)
          clear fig
          figure1 = figure;
          plot(Hpixelnum, Hchl) 
          title(baseFileName)
          % select center and boundaries of transect
          hold on
          Hpts = ginput(3);
        
          % name values from selection
          Hbound1pixel = round(Hpts(1,1));
          Hbound1chl = HProfile(Hbound1pixel,6);
          Hcenterpixel = round(Hpts(2,1));
          Hcenterchl = HProfile(Hcenterpixel,6);
          Hbound2pixel = round(Hpts(3,1));
          Hbound2chl = HProfile(Hbound2pixel,6);
          
          % record center lat and lon
          Hindex = find(HProfile(:,1) == Hcenterpixel)
          
          Hcenterlat = HProfile(Hindex, 4);
          Hcenterlon = HProfile(Hindex, 5);
          
          % find where profile crosses 1/2 average of bound chl values
          Hbaselinechl = (Hbound1chl + Hbound2chl)/2; % average of bounds = baseline
          Hamplitudechl = Hcenterchl - Hbaselinechl; % amplitude of chl
          Hhalfampchl = Hamplitudechl/2; % value at half of amplitude 
          Hhalfmaxchl = Hcenterchl - Hhalfampchl; % chl value at half max
          
          % interpolate between lat, lon and chl values in matrix
          % in order to then get exact distance at half max
          Hx = Hcumdist;
          Hy = Hchlavg;
          Hx_fine = linspace(Hcumdist(1,1),Hcumdist(end),100);
          [Hx, Xindex] = unique(Hx);
          Hy_fine = interp1(Hx, Hchlavg(Xindex), Hx_fine);
          clear figure
          figure2 = figure;
          plot(Hcumdist, Hchlavg, 'ro', Hx_fine, Hy_fine, ':.')
          
          % find full width half max (km)
          clear Hinterpmatrix
          clear Hhalfinterpmatrix
          Hinterpmatrix = [Hx_fine(:), Hy_fine(:)];% create matrix of interpolated values
          Hhalfinterpmatrix = Hinterpmatrix(Hinterpmatrix(:,2) >= Hhalfmaxchl, :);% isolate upper half of profile
          Hfirst_halfmaxdist = Hhalfinterpmatrix(1,1);    % first value
          Hlast_halfmaxdist = Hhalfinterpmatrix(end,1);   %last value
          
          Horiz_FWHM = Hlast_halfmaxdist - Hfirst_halfmaxdist;
          
          % find gradient to left and right of center & STDEV
          Hfirst_diff = Hcenterchl - Hbound1chl; % difference between center chl and left bound
          Hindex1 = find(HProfile(:,1) == Hbound1pixel); % location of bound1
          % this is creating a problem because it is finding two locations
          % change to using pixel instead of chlorophyll
          Hbound1_stdev = HProfile(Hindex1, 7); % bound1 stdev stdev
          Hbound1dist = Hcumdist(Hindex1); % cumulative distance @ bound1
          % Hfirst_diff_stdev = (Hbound1_stdev + HcenterSTDEV)/2;

          Hlast_diff = Hcenterchl - Hbound2chl; % difference between center chl and right bound
          Hindex2 = find(HProfile(:,1) == Hbound2pixel); % location of bound2
          Hbound2_stdev = HProfile(Hindex2, 7); % bound2 chl stdev
          %Hlast_diff_stdev = (Hbound2_stdev + HcenterSTDEV)/2;
          
          Hcenter_dist = Hcumdist(Hindex); % cumulative distance @ center
          HcenterSTDEV = HProfile(Hindex, 7); % chl stdev @ center
          Hbound2dist = Hcumdist(Hindex2); % cumulative distance @ bound2
          
          Hfirst_dist = Hcenter_dist - Hbound1dist; % distance btw centre and bound1
          Hlast_dist = Hbound2dist - Hcenter_dist; % distance btw centre and bound2
          
          Hfirst_gradient = Hfirst_diff / Hfirst_dist; % center --> bound1 gradient
          Hlast_gradient = Hlast_diff / Hlast_dist; % center --> bound1 gradient
          
          % find average gradient for horizontal
          Havg_gradient = (Hfirst_gradient + Hlast_gradient)/2
          %avg_gradient_logged = ((log10(first_diff)/first_dist) + (log10(first_diff)/last_dist))/2
          Havg_gradient_logged_last = log10(Havg_gradient)
          
          close(figure1)
          close(figure2)
    %  else 
     %     disp('not horizontal transect')
          
      %end
          
      % determine if vertical transect
      %if strfind(baseFileName, 'Vertic') > 1
      
      k = k + 1;
          baseFileName = eddyFiles(k).name; 
          formation = baseFileName(1:1);
          Vcount = Vcount+1;
          disp('VERTICAL TRANSECT NUMBER')
          disp(Vcount)
          
          Vbreaklocation = strfind(baseFileName, 'V');
          VtransectNum = baseFileName(2:Vbreaklocation-1);
          VtransectNum = str2double(VtransectNum);
          
          
           % read profile
          VProfile = csvread(baseFileName, 1, 0);
          Vlats = VProfile(:,4);
          Vlons = VProfile(:,5);
          Vpixelnum = VProfile(:,1);
          Vdist = m_lldist([Vlons], [Vlats], 'km');
          Vcumdist = cumsum(Vdist); % cumulative distance (km)
          Vchl = VProfile(:, 6);
          Vstdev = VProfile(:,7);
          Vchlavg = 0.5 * (Vchl(1:end-1) + Vchl(2:end));
          Vlogchl = log10(Vchl);
          
          % plot chl / pixel 
          % RECORD CLASS INFO FOR EACV IN SPREADSVEET!!! (A, B, C, P)
          clear fig
          figure1 = figure;
          plot(Vpixelnum, Vchl) 
          title(baseFileName)
          % select center and boundaries of transect
          hold on
          Vpts = ginput(3);
         
          % name values from selection
          Vbound1pixel = round(Vpts(1,1));
          Vbound1chl = VProfile(Vbound1pixel,6);
          Vcenterpixel = round(Vpts(2,1));
          Vcenterchl = VProfile(Vcenterpixel,6);
          Vbound2pixel = round(Vpts(3,1));
          Vbound2chl = VProfile(Vbound2pixel,6);
          
          % record center lat and lon
          Vindex = find(VProfile(:,1) == Vcenterpixel);
          Vcenterlat = VProfile(Vindex, 4);
          Vcenterlon = VProfile(Vindex, 5);
          
          % find where profile crosses 1/2 average of bound chl values
          Vbaselinechl = (Vbound1chl + Vbound2chl)/2; % average of bounds = baseline
          Vamplitudechl = Vcenterchl - Vbaselinechl; % amplitude of chl
          Vhalfampchl = Vamplitudechl/2; % value at half of amplitude 
          Vhalfmaxchl = Vcenterchl - Vhalfampchl; % chl value at half max
          
          % interpolate between lat, lon and chl values in matrix
          % in order to then get exact distance at half max
          Vx = Vcumdist;
          Vy = Vchlavg;
          Vx_fine = linspace(Vcumdist(1,1),Vcumdist(end),100);
          [Vx, Xindex] = unique(Vx);
          Vy_fine = interp1(Vx, Vchlavg(Xindex), Vx_fine);
          clear figure
          figure2 = figure
          plot(Vcumdist, Vchlavg, 'ro', Vx_fine, Vy_fine, ':.')
          
          % find full width half max (km)
          clear Vinterpmatrix
          clear Vhalfinterpmatrix
          clear Vfirst_halfmaxdist
          clear Vlast_halfmaxdist
          Vinterpmatrix = [Vx_fine(:), Vy_fine(:)];% create matrix of interpolated values
          Vhalfinterpmatrix = Vinterpmatrix(Vinterpmatrix(:,2) >= Vhalfmaxchl, :);% isolate upper half of profile
          Vfirst_halfmaxdist = Vhalfinterpmatrix(1,1);    % first value
          Vlast_halfmaxdist = Vhalfinterpmatrix(end,1);   %last value
          
          clear Vertic_FWHM
          Vertic_FWHM = Vlast_halfmaxdist - Vfirst_halfmaxdist;
          
          % find gradient to left and right of center & STDEV
          clear Vfirst_diff
          clear Vindex1
          clear Vbound1_stdev
          clear Vbound1dist
          Vfirst_diff = Vcenterchl - Vbound1chl; % difference between center chl and left bound
          Vindex1 = find(HProfile(:,1) == Vbound1pixel); % location of bound1
          Vbound1_stdev = VProfile(Vindex1, 7); % bound1 stdev stdev
          Vbound1dist = Vcumdist(Vindex1); % cumulative distance @ bound1
          %Vfirst_diff_stdev = (Vbound1_stdev + VcenterSTDEV)/2;

          clear Vlast_diff 
          clear Vindex2 
          clear Vbound2_stdev 
          Vlast_diff = Vcenterchl - Vbound2chl; % difference between center chl and right bound
          Vindex2 = find(HProfile(:,1) == Vbound2pixel);; % location of bound2
          Vbound2_stdev = VProfile(Vindex2, 7); % bound2 chl stdev
          %Vlast_diff_stdev = (Vbound2_stdev + VcenterSTDEV)/2;
          
          clear Vcenter_dist
          clear VcenterSTDEV
          clear Vbound2dist
          Vcenter_dist = Vcumdist(Vindex); % cumulative distance @ center
          VcenterSTDEV = VProfile(Vindex, 7); % chl stdev @ center
          Vbound2dist = Vcumdist(Vindex2); % cumulative distance @ bound2
          
          clear Vfirst_dist
          clear Vlast_dist
          Vfirst_dist = Vcenter_dist - Vbound1dist; % distance btw centre and bound1
          Vlast_dist = Vbound2dist - Vcenter_dist; % distance btw centre and bound2
          
          clear Vfirst_gradient
          clear Vlast_gradient
          Vfirst_gradient = (Vfirst_diff / Vfirst_dist); % center --> bound1 gradient
          Vlast_gradient = (Vlast_diff / Vlast_dist); % center --> bound1 gradient
          
          clear Vavg_gradient
          clear Vavg_gradient_logged_last
          % find average gradient for horizontal
          Vavg_gradient = (Vfirst_gradient + Vlast_gradient)/2
          %avg_gradient_logged = ((log10(first_diff)/first_dist) + (log10(first_diff)/last_dist))/2
          Vavg_gradient_logged_last = log10(Vavg_gradient)
          
          close(figure1)
          close(figure2)
          
    %  else
     %     disp('not vertical transect')
          
      %end

      
      %% average for both transects (all data for specified eddy(k))
     % A = exist ('HtransectNum')
      %B = exist ('VtransectNum')
      
      
      %if A >= 1 && B >=1 && VtransectNum == HtransectNum
          
          clear Eddy_gradient
          clear FWHM
          clear E_centerlat
          clear E_centerlon
          clear Absolute_center_chl
          clear Center_chl_stdev
          clear Absolute_Boundary_chl
          clear Bounds_chl_stdev
          
          Eddy_gradient = log10((Vavg_gradient + Havg_gradient)/2); % average gradient for N S E & W boundaries
          FWHM = (Vertic_FWHM + Horiz_FWHM)/2; % average E-W & N-S FWHM
          
          E_centerlat = (Vcenterlat + Hcenterlat)/2; % center latitude of eddy
          E_centerlon = (Vcenterlon + Hcenterlon)/2;% center longitude of eddy
          
          Absolute_center_chl = log10((Vcenterchl + Hcenterchl)/2); % logged center chl
          Center_chl_stdev = log10((VcenterSTDEV + HcenterSTDEV)/2); % logged center chl stdev
          
          Absolute_boundary_chl = log10((Vbound1chl + Vbound2chl + Hbound1chl + Hbound2chl)/4); % logged boundary chl
          Bounds_chl_stdev = log10((Vbound1_stdev + Vbound2_stdev + Hbound1_stdev + Hbound2_stdev)/4); % logged boundary chl stdev
     % else
      %    disp('no match')
      %end


    %% WRITE DATA TO EXISTING FILE
   % C = exist ('Eddy_gradient')
    %if C >= 1
    
    clear outputarray

    ddir2 = 'YOUR OUTPUT DIRECTORY HERE';
    cd(ddir2)

    outputarray = [HtransectNum; Eddy_gradient; FWHM; E_centerlat; E_centerlon; Absolute_center_chl;...
        Center_chl_stdev; Absolute_boundary_chl; Bounds_chl_stdev].'; % CHECK DIMENSION 

    dlmwrite('EddyDataAppend2.csv',outputarray,'delimiter',',', '-append')

  %  else
   %     disp('no output')

    %end
    cd(ddir)
    
    k = k + 1;
end

%% OUTER LEVEL DIRECTORY
clear variables;
ddir1 = 'YOUR DIRECTORY TO SATELLITE DATA HERE';
cd(ddir1)
addpath(genpath('/Applications/m_map')) % is this an ok way to add path??

%% TEST IF M_MAP IS WORKING correctly (example of some of oregon coast)
%m_proj('oblique mercator','longitudes',[-132 -125], ...
           %'latitudes',[56 40],'direction','vertical','aspect',.5);
%m_coast;
%m_grid;
% note that longitudes are signed (-/+) and everything is in in decimal
% degrees
% worth downloading ETOPO1 bathymetry & GSHHG coastline??? 

%% choose relevant grid spacing for geographic area

% WHEN CALCULATED BY HAND:
% @ 25°N, 300m res is 0.00298° LON res
% @ 30.5°N, 300m res is 0.00314° LON res
% 300m res in degrees LAT is 0.00270°

% TEST SPACING WITH CODE:
% m_lldist([125, 125.00298], [25, 25], 'km') % based on above calcs, gives 0.3007 km
% m_lldist([125, 125.00314], [30.5, 30.5], 'km') % based on above calcs, gives 0.3012 km

% m_lldist([125, 125], [25, 25.00270], 'km') % based on above calcs, gives 0.3006 km

% ACHIEVE 300m RESOLUTION:
%m_lldist([125, 125.002974], [25, 25], 'km') % trial & error, gives 0.3000 km
%m_lldist([125, 125.003128], [30.5, 30.5], 'km') % trial & error, gives 0.3000 km
% use .003° lon x .0027 lat res for match ups

%m_lldist([125, 125], [30, 25.002695], 'km') % trial & error, gives 0.3000 km

% CALCULATED 0.01° OFFSET at northern and southern limits of domain:
%m_lldist([125, 125.01], [25, 25], 'km') % ans = 1.0089
m_lldist([125, 125.01], [30, 30], 'km') % ans = 0.9592 DIFFERENCE = 0.0497 km (49.7 m)

%% Create new grid
dx = 0.003; % lon res @ 30.5°N
dy = 0.0027; % lat res
lon1 = 125; lon2 = 135; lat1 = 25; lat2 = 30.5; % define ROI
lonspace2 = [lon1 : dx : lon2]; % define lon axis spacing/grid
latspace2 = [lat1 : dy : lat2]; % define lat axis spacing/grid
[mylat, mylon] = meshgrid(lonspace2, latspace2); % define grid array (??)


%% ENTER NESTED DIRECTORIES to locate .SEN3 files
 for iYear = 2019
    % change into the year's directory
   
    cd([ddir1 num2str(iYear)]);
   
    for iMonth = 1:12
        % do we have this month??
        clear result;
                
        if iMonth < 10
            thisMonth = ['0' num2str(iMonth)];
        else
            thisMonth = num2str(iMonth);
        end
        
        result = isfolder(thisMonth);
        if result == 1
            % if this month directory exists, change to that directory
            cd([ddir1 num2str(iYear) '/' thisMonth])
        
            % for each day, do we have that day?
            for iDay = 1:31
                % do we have this day? (flag)
                clear result;

                if iDay < 10
                    thisDay = ['0' num2str(iDay)];
                else
                    thisDay = num2str(iDay);
                end
                
                result1 = isfolder(thisDay);
                if result1 == 1
                    cd([ddir1 num2str(iYear) '/' thisMonth '/' thisDay])
               
              
                    % look for files ending in .SEN3
                    dirlist = dir('*.SEN3');
                   
                    % (~ -= not... if not empty...)
                    if ~isempty(dirlist)
                        for iDir = 1:length(dirlist)
                            cd(dirlist(iDir).name)
                            thisdir = dirlist(iDir).name;
                            % got to file directory
                            % assign chl2 (+ everything you want to regrid)
                            % (chl2 NN & chl2 OC4 + also for errors)
%                             ChlNN2 = ones(length(lonspace2),length(latspace2))*nan;
%                             ChlOC42 = ones(length(lonspace2),length(latspace2))*nan;
%                             ChlNNerr2 = ones(length(lonspace2),length(latspace2))*nan;
%                             ChlOC4err2 = ones(length(lonspace2),length(latspace2))*nan;
%                             myWQSF2 = ones(length(lonspace2),length(latspace2))*nan;
                            ChlNN2 = NaN(length(lonspace2),length(latspace2)); %chlorophyll neural network
                            ChlOC42 = NaN(length(lonspace2),length(latspace2));
                            ChlNNerr2 = NaN(length(lonspace2),length(latspace2));
                            ChlOC4err2 = NaN(length(lonspace2),length(latspace2));
                            myWQSF2 = uint64(NaN(length(lonspace2),length(latspace2)));                            
                            
                            
                            % USE NCREAD TO GET CHL & GEOCOORDS FILES & ncdisp to see if array
                            ChlOC4 = ncread('chl_oc4me.nc', 'CHL_OC4ME');
                            ChlOC4err = ncread('chl_oc4me.nc', 'CHL_OC4ME_err');
                          
                            % ncdisp('chl_nn.nc') only use this to manually
                            % debug
                            ChlNN = ncread('chl_nn.nc', 'CHL_NN');
                            ChlNNerr = ncread('chl_nn.nc', 'CHL_NN_err');
                            %if you want to plot the values use plot(ChlNNerr(:),'.')
                            
                       
                            % apply limit checks
                            clear ibad;
                            
                            ibad = find(ChlNN(:)<-1.99 | ChlNN(:)>log10(5));
                            ChlNN(ibad)=nan;
                            
                            ibad = find(ChlOC4(:)<-1.99 | ChlOC4(:)>log10(5));
                            ChlOC4(ibad)=nan;
                            
                            clear ibad;
                            
                            % load WQSF file too so regrid flags too
                            myWQSF = ncread('wqsf.nc', 'WQSF');

                            
                            % ncdisp('geo_coordinates.nc')
                            lon = ncread('geo_coordinates.nc','longitude');
                            lat = ncread('geo_coordinates.nc','latitude');
                            
                            % find good data values and test in right
                            % domain (ROID)
                            
                             % first test in relation to western side
                                % then eastern side
                            clear iok; iok = find(~isnan(ChlNN(:)) & ...
                              lon(:) >= lon1 & lon(:) <= lon2 & lat(:)>= lat1 & lat(:) <= lat2);
                          if ~isempty(iok)
                              
                              
                              % create sub domain versions with variables,
                              % to be able to regrid all pixels at once...
                              % for lon/lat, both chlorophylls & their
                              % errors
                              clear lonb; lonb = lon(iok);
                              clear latb; latb = lat(iok);
                              clear ChlNNb; ChlNNb = ChlNN(iok);
                              clear ChlNNerrb; ChlNNerrb = ChlNNerr(iok);
                              clear ChlOC4b; ChlOC4b = ChlOC4(iok);
                              clear ChlOC4errb; ChlOC4errb = ChlOC4err(iok);
                              clear myWQSFb; myWQSFb = myWQSF(iok);
                              
                              % place all pixels in new array 
                              clear m n;
                              m = ceil((lonb-lon1)/dx);
                              n = ceil((latb-lat1)/dy);
                              
                              % test edges because ceiling function rounds
                              % up - might go off eastern edge
                              clear inull; inull=find(m==0); if ~isempty(inull); m(inull)= 1 ; end
                              clear inull; inull=find(n==0); if ~isempty(inull); n(inull) = 1; end
                              
                              % for each pixel, place all iok values into new grid
                              for ipix = 1:length(m)
                                ChlNN2(m(ipix),n(ipix)) = ChlNNb(ipix);
                                ChlOC42(m(ipix),n(ipix)) = ChlOC4b(ipix);
                                ChlNNerr2(m(ipix),n(ipix)) = ChlNNerrb(ipix);
                                ChlOC4err2(m(ipix),n(ipix)) = ChlOC4errb(ipix);
                                myWQSF2(m(ipix),n(ipix)) = myWQSFb(ipix);
                              end
                              outfile = ['YOUR OUTPUT DIRECTORY HERE' thisdir(17:31) '.mat'];
                              save(outfile, 'ChlNN2', 'ChlOC42', 'ChlNNerr2', 'ChlOC4err2', 'myWQSF2', 'latspace2', 'lonspace2' );
                          end
                          cd ..
                        end
                    end
                else
                cd([ddir1 num2str(iYear) '/' thisMonth]);
                end
                cd([ddir1 num2str(iYear) '/' thisMonth]);
            end
            cd([ddir1  num2str(iYear)]);
        end
    end
 end
                               
%%                                
                            
% regrid flags (to be applied during match ups)  

% need to figure out what the errors mean??
% ANSWER: 'USE OF SENTINEL L2 ERRORS IS
% NOT RECOMMENDED - ONLY FOR QUALITATIVE ASSESSMENT - HAVE NOT BEEN
% VERIFIED'




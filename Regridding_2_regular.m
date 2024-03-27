%% Once we have generate data of year month day lon lat Ncol and BCmass it is saved as 
clear all;
close all;

% Read the data files
dhaka_data = readmatrix('dtaNcolmass_DH.csv');

% Define the grid parameters for dhaka
dhaka_lon_min = 88;
dhaka_lon_max = 92;
dhaka_lat_min = 22.0;
dhaka_lat_max = 25.5;
lon_step = 0.03;
lat_step = 0.07;
% Create the common grid for dhaka
[commongrid753x, commongrid753y] = meshgrid(dhaka_lon_min:lon_step:dhaka_lon_max, dhaka_lat_min:lat_step:dhaka_lat_max);
[x1, x2] = size(commongrid753x);

dates = (dhaka_data(:, (1:3)));
unique_dates = unique(dates, 'rows');
%unique_dates = unique_dates(29:196,:);

% Initialize the 3D layered matrix
layered_data = nan(x1, x2, 6, length(unique_dates));
%regridded_data_dhaka = [];
for i = 1:size(unique_dates, 1)
    % Get the data for the current date
    current_date = unique_dates(i, :);
    date_data = dhaka_data(ismember(dhaka_data(:, 1:3), current_date, 'rows'), :);
    % Extract lon, lat, BCmass, and Ncol for the current date
    may2data = date_data(:, 4:7);
    % Check the length of may2data
    l1 = length(may2data(:,1));
    % Initialize the arrays for regridding
    commonmass753mass = nan(x1, x2);
    commonmass753num = nan(x1, x2);
    commonmass753massw = nan(x1, x2);
    for ii = 1:x1-1
    for jj = 1:x2-1
        tw = [];
        ta = [];
        for kk = 1:l1
            %if ((may2data(kk,2)-0.015)>=commongrid753y(ii,jj)) && ((may2data(kk,2)-0.015)<=commongrid753y(ii+1,jj))
            %     [ii,jj,kk,commongrid753y(ii,jj),commongrid753y(ii+1,jj),may2data(kk,2)-0.015]
            %end
            if ((may2data(kk,1)-0.015)>=commongrid753x(ii,jj)) && ((may2data(kk,1)-0.015)<=commongrid753x(ii,jj+1)) && ...
                    ((may2data(kk,2)-0.035)>=commongrid753y(ii,jj)) && ((may2data(kk,2)-0.035)<=commongrid753y(ii+1,jj))
                xdist = abs(commongrid753x(ii,jj+1) - (may2data(kk,1)-0.015));
                ydist = abs(commongrid753y(ii+1,jj) - (may2data(kk,2)-0.035));
                tw = xdist*ydist / (0.07*0.03);
                tna = may2data(kk,3);
                tma = may2data(kk,4);
                %[xdist,ydist,tw]
            end
        end
        if isempty(tw)==0
            %tw
            commonmass753massw(ii,jj) = sum(tw);
            commonmass753mass(ii,jj) = sum(tw.*tma)/sum(tw);
            commonmass753num(ii,jj) = sum(tw.*tna)/sum(tw);
        end
    end   
    end
    figure('Position', [100 100 2200 1000]);
    subplot(1,3,1);
    pcolor(commongrid753x,commongrid753y,commonmass753mass);
     grid off
    colorbar;
    title('BCmass');
   
    
    subplot(1,3,2);
    pcolor(commongrid753x,commongrid753y,commonmass753num);
    grid off
    colorbar;
    title('Ncol');
    
    
    subplot(1,3,3);
    pcolor(commongrid753x,commongrid753y,commonmass753massw);
    grid off
    colorbar;
    title('Weights');
    
    
    sgtitle(sprintf('Date: %d-%d-%d', current_date(1), current_date(2), current_date(3)));
    saveas(gcf, sprintf('plots_%d_%d_%d.png', current_date(1), current_date(2), current_date(3)));
    close;
    
   % Create the layered data for the current date
    time = repmat(current_date, [x1*x2,1]);
    time2D = reshape(time, [x1, x2, 3]);
    lon = commongrid753x;
    lat = commongrid753y;
    bcmass = commonmass753mass;
    ncol = commonmass753num;
    weights = commonmass753massw;
    save(sprintf('DHlayered_data_%d_%d_%d.mat', current_date(1), current_date(2), current_date(3)), ...
         'time2D', 'lon', 'lat', 'bcmass', 'ncol', 'weights');
end

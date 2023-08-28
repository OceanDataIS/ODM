function createDailyNC(data,dataf,lon,lat,t,ncfile,lag)
%%
lag = lag-1;
Rate = 9 ; 
% Delete the nc file if exists
if exist(ncfile)
    delete(ncfile) ;
end
nx = length(lon) ; ny = length(lat) ; nt = length(t) ; time = t;
%% Create variables
nccreate(ncfile,'originalSST','Dimensions',{'lon' nx 'lat' ny},'FillValue',-9999,'DeflateLevel',Rate);
nccreate(ncfile,'filledSST','Dimensions',{'lon' nx 'lat' ny},'FillValue',-9999,'DeflateLevel',Rate);
nccreate(ncfile,'lon','Dimensions',{'lon' nx},'DeflateLevel',Rate);
nccreate(ncfile,'lat','Dimensions',{'lat' ny},'DeflateLevel',Rate);
nccreate(ncfile,'time','Dimensions',{'time' nt},'DeflateLevel',Rate);
% ncdisp(ncfile);
%% write dimensions
%Latitude: -30N to 30N
ncwrite(ncfile,'lat',lat);
ncwriteatt(ncfile,'lat','long_name','Latitude');
ncwriteatt(ncfile,'lat','units', 'degrees_north');
ncwriteatt(ncfile,'lat','axis','Y');
ncwriteatt(ncfile,'lat','point_spacing','even');
ncwriteatt(ncfile,'lat','standard_name', 'latitude');

%Longitude: 30E to 120E, 0.625 deg resolution, denoted by 225
ncwrite(ncfile,'lon', lon);
ncwriteatt(ncfile,'lon','long_name','Longitude');
ncwriteatt(ncfile,'lon','units', 'degrees_east');
ncwriteatt(ncfile,'lon','axis','X');
ncwriteatt(ncfile,'lon','point_spacing','even');
ncwriteatt(ncfile,'lon','modulo', 360);
ncwriteatt(ncfile,'lon','standard_name', 'longitude');

% Time : 15 days Interval
t1 = datetime(1950,01,01,0,0,0);
t2 = time(end-lag);
tt = t2-datenum(t1);
ncwrite(ncfile,'time',tt);
% ncwrite(ncfile,'time',time(end-lag));
ncwriteatt(ncfile,'time','units','days since 1950-01-01 00:00:00');
ncwriteatt(ncfile,'time','calendar', 'gregorian');
ncwriteatt(ncfile,'time','axis','T');
ncwriteatt(ncfile,'time','standard_name', 'time');

%% write variable data and attributes
ncwrite(ncfile,'originalSST', data(:,:,end-lag));
ncwriteatt(ncfile,'originalSST','long_name','Sea Surface Temparature');
ncwriteatt(ncfile,'originalSST','units', 'degC');
ncwriteatt(ncfile,'originalSST','history', 'From noaa-19');

ncwrite(ncfile,'filledSST', dataf(:,:,end-lag))
ncwriteatt(ncfile,'filledSST','long_name','Sea Surface Temparature');
ncwriteatt(ncfile,'filledSST','units', 'degC');
ncwriteatt(ncfile,'filledSST','history', 'From noaa-19');

disp([ncfile 'NetCDF created']);
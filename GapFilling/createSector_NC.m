function createSector_NC(lat,lon,data,fname,pth,vName,units,longName,history,time)
%%
Rate = 9 ;
% Create NC file and write lon, lat and Chla/SST
ncfile = [pth filesep fname];
% Delete the nc file if exists
if exist(ncfile)
    delete(ncfile) ;
end
nx = length(lon) ; ny = length(lat); nt = length(time);
data = reshape(data,nx,ny,nt);
%% Create variables
nccreate(ncfile,'time','Dimensions',{'time', Inf},'DeflateLevel',Rate);
nccreate(ncfile,'lat','Dimensions',{'lat' ny},'DeflateLevel',Rate);
nccreate(ncfile,'lon','Dimensions',{'lon' nx},'DeflateLevel',Rate);
nccreate(ncfile,vName,'Dimensions',{'lon' nx 'lat' ny 'time' Inf},'FillValue',-9999,'DeflateLevel',Rate);
% nccreate(ncfile, 'time', 'Datatype', 'char');
%% write dimensions
%Latitude: -30N to 30N
% ncwrite(ncfile,'lat',lat(1:2:end));
ncwrite(ncfile,'lat',lat);
ncwriteatt(ncfile,'lat','long_name','Latitude');
ncwriteatt(ncfile,'lat','units', 'degrees_north');
ncwriteatt(ncfile,'lat','axis','Y');
ncwriteatt(ncfile,'lat','point_spacing','even');
ncwriteatt(ncfile,'lat','standard_name', 'latitude');

%Longitude: 30E to 120E, 0.625 deg resolution, denoted by 225
% ncwrite(ncfile,'lon', lon(1:2:end));
ncwrite(ncfile,'lon', lon);
ncwriteatt(ncfile,'lon','long_name','Longitude');
ncwriteatt(ncfile,'lon','units', 'degrees_east');
ncwriteatt(ncfile,'lon','axis','X');
ncwriteatt(ncfile,'lon','point_spacing','even');
ncwriteatt(ncfile,'lon','modulo', 360);
ncwriteatt(ncfile,'lon','standard_name', 'longitude');

% Time
t1 = datetime(1950,01,01,0,0,0);
t2 = time;
ncwrite(ncfile,'time',t2-datenum(t1));
ncwriteatt(ncfile,'time','standard_name', 'time');
ncwriteatt(ncfile,'time','units','days since 1950-01-01 00:00:00');
ncwriteatt(ncfile,'time','calendar', 'gregorian');
ncwriteatt(ncfile,'time','axis','T');


%% write variable data and attributes

ncwrite(ncfile,vName, data);
ncwriteatt(ncfile,vName,'long_name',longName);
ncwriteatt(ncfile,vName,'units', units);
ncwriteatt(ncfile,vName,'history', history);

disp('NetCDF created');
% ncdisp(ncfile);

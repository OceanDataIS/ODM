function gapfillingsectors(pth,ncfile)
%%
file1 = 'E:\D BackUp\PPL Works\Kameshwari\wind_rose\Global_resized.nc';
x1 = ncread(file1,'lon') ; y1 = ncread(file1,'lat') ;
[X1,Y1] = meshgrid(x1,y1) ; H1 = ncread(file1,'bathymetry') ;
%
file2 = ncfile;
% x2 = ncread(file2,'lon') ; y2 = ncread(file2,'lat') ;
% t = ncread(file2,'time') ;
% data = ncread(file2,'SST');
load(ncfile)
x2 = lon; y2 = lat; t = time;

%
[X2,Y2] = meshgrid(x2,y2) ;
H2 = interp2(X1,Y1,H1',X2,Y2) ;
mask=H2;
mask(H2>0)=0;
mask(H2<0)=1;
%
lag = 120; % No.of passes/days in consideration
cd('E:\CBackUp\dineof')
% [dataf,eofs] = run(data(1:2:end,1:2:end,:), t, mask(1:2:end,1:2:end)', 'nev',5,'plot',1);
[dataf,eofs] = run(data(:,:,length(t)-lag:end), t(length(t)-lag:end), mask', 'nev',5,'plot',1);

movefile('E:\CBackUp\dineof\dummy_eof.log',[file2(1:end-4) '_eof_' datestr(now,'dd.mm.yyyy') '.log'])
cd(pth)
save([file2(1:end-4) '_filled_' datestr(now,'dd.mm.yyyy') '.mat'], '-v7.3')


%% Create netCDF file 
%function Mat2NC(data,dataf,lon,lat,T,mask,eofs,fName)
%%
Rate = 9 ; clear time
% Create NC file and write lon, lat and Chla/SST
ncfile = [file2(1:end-4) '_filled_' datestr(now,'dd.mm.yyyy') '.nc'];
% Delete the nc file if exists
if exist(ncfile)
    delete(ncfile) ;
end
nx = length(x2) ; ny = length(y2) ; k=1;
% nt = length(t) ; time = t;
nt=length(t(length(t)-lag:end)); time=t(length(t)-lag:end); 
%% Create variables
nccreate(ncfile,'originalSST','Dimensions',{'lon' nx 'lat' ny 'time' nt},'FillValue',-9999,'DeflateLevel',Rate);
nccreate(ncfile,'filledSST','Dimensions',{'lon' nx 'lat' ny 'k' 1 'time' nt},'FillValue',-9999,'DeflateLevel',Rate);
nccreate(ncfile,'mask','Dimensions',{'lon' nx 'lat' ny },'DeflateLevel',Rate);
nccreate(ncfile,'lat','Dimensions',{'lat' ny},'DeflateLevel',Rate);
nccreate(ncfile,'lon','Dimensions',{'lon' nx},'DeflateLevel',Rate);
nccreate(ncfile,'time','Dimensions',{'time' nt},'DeflateLevel',Rate);

nccreate(ncfile,'lftvec','Dimensions',{'lon' nx 'lat' ny 'p' size(eofs.rghvec,2)},'DeflateLevel',Rate);
nccreate(ncfile,'rghvec','Dimensions',{'z' nt 'p' size(eofs.rghvec,2)},'DeflateLevel',Rate);
nccreate(ncfile,'varEx','Dimensions',{'p' size(eofs.rghvec,2) 'x' 1 },'DeflateLevel',Rate);
nccreate(ncfile,'varLab','Dimensions',{'p' size(eofs.rghvec,2) 'y' 1},'DeflateLevel',Rate);
nccreate(ncfile,'vlsng','Dimensions',{'p' size(eofs.rghvec,2) 'x' 1},'DeflateLevel',Rate);
nccreate(ncfile,'P','Dimensions',{'p' size(eofs.rghvec,2)},'DeflateLevel',Rate);
nccreate(ncfile,'mean','Dimensions',{'x' 1},'DeflateLevel',Rate);
ncdisp(ncfile);
%% write dimensions
%Latitude: -30N to 30N
ncwrite(ncfile,'lat',y2);
ncwriteatt(ncfile,'lat','long_name','Latitude');
ncwriteatt(ncfile,'lat','units', 'degrees_north');
ncwriteatt(ncfile,'lat','axis','Y');
ncwriteatt(ncfile,'lat','point_spacing','even');
ncwriteatt(ncfile,'lat','standard_name', 'latitude');

%Longitude: 30E to 120E, 0.625 deg resolution, denoted by 225
ncwrite(ncfile,'lon', x2);
ncwriteatt(ncfile,'lon','long_name','Longitude');
ncwriteatt(ncfile,'lon','units', 'degrees_east');
ncwriteatt(ncfile,'lon','axis','X');
ncwriteatt(ncfile,'lon','point_spacing','even');
ncwriteatt(ncfile,'lon','modulo', 360);
ncwriteatt(ncfile,'lon','standard_name', 'longitude');

% Time : 15 days Interval
t1 = datetime(1950,01,01,0,0,0);
t2 = time;
tt = t2-datenum(t1);
ncwrite(ncfile,'time',tt);
ncwriteatt(ncfile,'time','units','days since 1950-01-01 00:00:00');
ncwriteatt(ncfile,'time','calendar', 'gregorian');
ncwriteatt(ncfile,'time','axis','T');
ncwriteatt(ncfile,'time','standard_name', 'time');

%% write variable data and attributes
dataO = data(:,:,length(t)-lag:end);
ncwrite(ncfile,'originalSST', dataO);
ncwriteatt(ncfile,'originalSST','long_name','Sea Surface Temparature');
ncwriteatt(ncfile,'originalSST','units', 'degC');
ncwriteatt(ncfile,'originalSST','history', 'From noaa-19');

ncwrite(ncfile,'filledSST',permute(dataf,[1 2 4 3]))
ncwriteatt(ncfile,'filledSST','long_name','Sea Surface Temparature');
ncwriteatt(ncfile,'filledSST','units', 'degC');
ncwriteatt(ncfile,'filledSST','history', 'From noaa-19');

ncwrite(ncfile,'mask', mask');
ncwriteatt(ncfile,'mask','long_name','MASK[Lon,Lat]');

ncwrite(ncfile,'lftvec',eofs.lftvec);
ncwrite(ncfile,'rghvec', eofs.rghvec);
ncwrite(ncfile,'varEx',eofs.varEx);
ncwriteatt(ncfile,'varLab','description',char(eofs.varLab));
ncwrite(ncfile,'vlsng',eofs.vlsng)
ncwrite(ncfile,'mean',eofs. mean);
ncwrite(ncfile,'P',eofs.P);

disp('NetCDF created');




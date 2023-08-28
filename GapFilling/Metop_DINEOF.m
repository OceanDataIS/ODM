clc;clear all;close all
%% Download files from Linux server using Python Script
cd 'E:\D BackUp\PPL Works\Vivek\Metop1Data\'
% Define the Python command and script filename
python_cmd = 'python';
script_filename = 'DownloadFiles_from_Linux_to_Windows.py';
% Construct the command to be executed
command = sprintf('%s %s', python_cmd, script_filename);
% Call the system command to execute the Python script
system(command);
cd 'E:\D BackUp\PPL Works\Vivek\Metop1Data\Metop1_Data_for_GapFilling\'
fprintf('****************************\n')
fprintf('Metop1 Data Copied Successfully !!!\n')
%% Segregate Day and Night Passes
pth = 'E:\D BackUp\PPL Works\Vivek\Metop1Data\Metop1_Data_for_GapFilling\';
list = dir([pth '\*.nc']);
listNP = dir([pth '\NightPasses\*.nc']);
listDP = dir([pth '\DayPasses\*.nc']);
ncfiles = cell2mat({list.name}'); % % get all passes file names
ncfilesNP = cell2mat({listNP.name}'); % get all night passes file names
ncfilesDP = cell2mat({listDP.name}'); % get all day passes file names
idxF = ismember({list.name}',[{listNP.name}'; {listDP.name}']);
ncfiles = ncfiles(~idxF,:);
for iloop = 1:size(ncfiles,1)
    idx = strfind(ncfiles(iloop,:),'-');
    tempSTR = ncfiles(iloop,idx(1)+1:idx(2)-2);
    if str2num(tempSTR(1:2))>12
        movefile([pth ncfiles(iloop,:)],[pth 'NightPasses'])
    else
        movefile([pth ncfiles(iloop,:)],[pth 'DayPasses'])
    end
end
delete *.nc
fprintf('****************************\n')
fprintf('Segregation of passes is done !!!\n')
%% Extract sector wise data from Pass data
listNP = dir([pth '\NightPasses\*.nc']);
secT = readtable('sectorsInfo.txt'); % Get sectors information
secT = [secT(1,:) ; secT(10,:)]; % Currently working on two sectors Gujarat and North AP
T = nan([],1); % time
for jloop = 1:length(listNP)
    file_in = [pth '\NightPasses\' listNP(jloop).name];
    lon = ncread(file_in,'lon');
    lat = ncread(file_in,'lat');
    time = ncread(file_in,'time');
    sst = ncread(file_in,'SST');
    T(jloop,1) = datenum(time)+datenum(datetime(1950,01,01,0,0,0));
    fname = listNP(jloop).name;
    longName = 'Sea Surface Temperature';
    units    = 'degC';
    history  = 'From AVHRR: metop-1 ';
    vName    = 'SST'; %variableName
    for kloop = 1:size(secT,1)
        try
            secPth = [pth '\NightPasses\Sectors\' secT.Sector{kloop}];
            mkdir(secPth)
            idxLat = find(lat>secT.minLAT(kloop) & lat<secT.maxLAT(kloop));
            idxLon = find(lon>secT.minLON(kloop) & lon<secT.maxLON(kloop));
            createSector_NC(lat(idxLat),lon(idxLon),sst(idxLon,idxLat),fname,...
                secPth,vName,units,longName,history,T(jloop))
            disp(secT.Sector{kloop}) 
        catch
            disp([secT.Sector{kloop} ' Error'])
        end
        clear idxLat idxLon
    end
end
movefile([pth '\NightPasses\*.nc'],[pth '\NightPasses\RawData\'])
fprintf('****************************\n')
fprintf('Sectors Extracted Successfully !!!\n')
%%
for secloop = 1:size(secT,1)
    listSec = dir([pth '\NightPasses\Sectors\' secT.Sector{secloop} '\*.nc']);
    ncfile = [pth '\NightPasses\Sectors\' secT.Sector{secloop} filesep listSec(1).name];
    lon = ncread(ncfile,'lon');
    lat = ncread(ncfile,'lat');
    data = nan(size(lon,1),size(lat,1),[]);
    for nloop = 1:length(listSec)
        ncfile = [pth '\NightPasses\Sectors\' secT.Sector{secloop} filesep listSec(nloop).name];
        t = ncread(ncfile,'time');
        time(nloop,1) = datenum(t)+datenum(datetime(1950,01,01,0,0,0));
        sst = ncread(ncfile,'SST');
        data(:,:,nloop) = sst;
    end
    cd '.\NightPasses\InputData\'
    delete([secT.Sector{secloop} '.mat'])
    save([secT.Sector{secloop} '.mat'],'-v7.3','data','lon','lat','time')
    cd ../..
    disp([secT.Sector{secloop} ' mat file is created '])
end
fprintf('****************************\n')
fprintf('Preparing Data for DINEOF\n')
%% Run DINEOF & DINCAE
clearvars -except secT pth
for secloop = 1:size(secT,1)
    tic
    mfilename = [pth '\NightPasses\InputData\' secT.Sector{secloop} '.mat'];
    gapfillingsectors([pth '\NightPasses\GapFilledData'],mfilename)
    toc
    cd('E:\D BackUp\PPL Works\Vivek\Metop1Data\Metop1_Data_for_GapFilling')
end

fprintf('****************************\n')
fprintf('Gap Filling Process is finished\n')
copyfile('.\NightPasses\InputData\Guj*.nc','\\172.16.1.144\ftp\Dineof\Gujarat')
movefile('.\NightPasses\InputData\Guj*.nc','.\NightPasses\GapFilledData\Gujarat')
copyfile('.\NightPasses\InputData\Nor*.nc','\\172.16.1.144\ftp\Dineof\North AP')
movefile('.\NightPasses\InputData\Nor*.nc','.\NightPasses\GapFilledData\North AndhraPradesh')
fprintf('****************************\n')
%% Create Daily netCDF files 
clc;clear all;close all
%
sector = {'North AndhraPradesh','Gujarat'}; 
for jloop = 1:length(sector)
    fDate = datestr(datetime('now'), 'dd.mm.yyyy');
    pth = ['E:\D BackUp\PPL Works\Vivek\Metop1Data\Metop1_Data_for_GapFilling\NightPasses\GapFilledData\' sector{jloop} filesep];
    ncfile = [sector{jloop} '_filled_' fDate '.nc'];
    lon = ncread([pth ncfile],'lon');
    lat = ncread([pth ncfile],'lat');
    dataO = ncread([pth ncfile],'originalSST');
    dataf = squeeze(ncread([pth ncfile],'filledSST'));
    time = ncread([pth ncfile],'time');
    t1 = datetime(1950,01,01,0,0,0);
    t2 = time;
    tt = datenum(t2)+datenum(t1);
    dt = datestr(tt(length(tt)-day(now)-4:end),'yyyymmdd_hhMMss');
    disp([sector{jloop} ' Sector'])
    fprintf('****************************\n')
    for iloop = length(dt)-14:length(dt)
        fname_out = [dt(iloop,:) '.nc'];
        createDailyNC(dataO,dataf,lon,lat,time,fname_out,iloop)
    end
    fprintf('****************************\n')
    movefile('E:\D BackUp\PPL Works\Vivek\Metop1Data\Metop1_Data_for_GapFilling\*.nc',['\\172.16.1.144\ftp\Dineof\' sector{jloop} '\Daily_ncfiles\'])
end
%% Data Visualization 
% subplot(1,2,1)
% pcolor(lon,lat,dataO(:,:,end-1)');shading interp;colorbar
% subplot(1,2,2)
% pcolor(lon,lat,dataf(:,:,end-1)');shading interp;colorbar

%%






%% Get modulation depth of PSTHs from early to late trials
%  Author - Aamir Abbasi
%  -----------------------------------------------------------------------
%% Modulation depth of PSTHs of M1 direct units
clear;clc;close all;
disp('running');
rootpath = '/Volumes/gulatitlab-eegdata/New_patient_data/EEG_data/'; % Change this path based on the location of the files in your computer
eegfiles =  { 'xxxxxx_14acb982-496f-4c83-9940-28c90449057c'...
    ,'xxxxxx_c2fbb91a-481e-407a-b1ad-81266f8691e5'...
    ,'xxxxxx_c6f109c9-6345-4cb3-855d-48e186fd27c9'...
    ,'xxxxxx_c9c68c96-575e-49c0-9563-6222e4a8144a'...
    ,'xxxxxx_fa652153-9360-44ff-8376-3e8486fc26e2'};
step = 20;
chan = [1 ];
temp=[];
for i=1:length(eegfiles)
    disp([rootpath,eegfiles{i},'.mat']);
    load([rootpath,eegfiles{i},'.mat']);
    fs = ALLEEG.srate; % sampling rate
    time = ALLEEG.times;
    eegsigs = ALLEEG.data;
    % creating differential signal like xltech
    temp=eegsigs;
    temp=temp([1:22],:);
    orders=[1,2,3,4,12,13,14,15,9,3,7,11,18,14,1,6,7,8,12,17,18,19; 2,3,4,5,13,14,15,16,3,7,11,18,14,20,6,7,8,5,17,18,19,16]';
    temp1=temp(orders(:,1),:);
    temp2=temp(orders(:,2),:);
    temp4=temp1(:,:)-temp2(:,:);
    eegsigs=temp4;
    eegraw=temp;
    %finished making differential signal
    epochs = [];
    bfr = 1:step:floor(length(eegsigs)/fs);
    title1=eegfiles{i};
    for j = bfr
        if j ~= bfr(end)
            epochs = cat(3,epochs,eegsigs(:,round(j*fs):round((j+step)*fs)));
        end
    end
    sleepepochs = fn_visualizeEpochs_TG_v2(epochs,[], title1);
    save([rootpath,'DATA_w_SleepEpochsID.mat'],'sleepepochs','epochs','eegsigs','eegraw','fs','time')
end

%%
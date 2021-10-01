%% EEG analyses for spindles

% load one patients data at a time

rootpath = '/Volumes/gulatitlab-eegdata/New_patient_data/EEG_data/'; % Change this path based on the location of the files in your computer
eegfiles =  { 'xxxxxx_14acb982-496f-4c83-9940-28c90449057c'...
    ,'xxxxxx_c2fbb91a-481e-407a-b1ad-81266f8691e5'...
    ,'xxxxxx_c6f109c9-6345-4cb3-855d-48e186fd27c9'...
    ,'xxxxxx_c9c68c96-575e-49c0-9563-6222e4a8144a'...
    ,'xxxxxx_fa652153-9360-44ff-8376-3e8486fc26e2'};
load('DATA_w_SleepEpochsID_xxxxxx_c6f109c9-6345-4cb3-855d-48e186fd27c9.mat')




%% Run this to concatenate sleep epochs and create artificial sleep_idx and artifact_idx for further analyses.


[eeg_new sleep_idx artifact_idx]=reconstruct_eeg(epochs, sleepepochs);


%% create differential signal for F, C, P and O channels to Fpz (GND; Ch 21)
%left channels
Frontal_L_diff=(eeg_new(:,6)-eeg_new(:,21));
Central_L_diff=(eeg_new(:,7)-eeg_new(:,21));
Parietal_L_diff=(eeg_new(:,8)-eeg_new(:,21));
Occipital_L_diff=(eeg_new(:,5)-eeg_new(:,21));

%right channels
Frontal_R_diff=(eeg_new(:,17)-eeg_new(:,21));
Central_R_diff=(eeg_new(:,18)-eeg_new(:,21));
Parietal_R_diff=(eeg_new(:,19)-eeg_new(:,21));
Occipital_R_diff=(eeg_new(:,16)-eeg_new(:,21));

eeg_new_diff=cat(2, Frontal_L_diff, Central_L_diff, Parietal_L_diff, Occipital_L_diff, Frontal_R_diff, Central_R_diff, Parietal_R_diff, Occipital_R_diff);

clear Frontal* Parietal* Central* Occipital*

%% detect spindles in the dataset in above 6 refenced channels

data.EEG=eeg_new_diff;


session_size=size(data.EEG,1);
data.sleep_idx=sleep_idx;
data.artifact_idx=artifact_idx;
data.Fs_LFP=256;

% regular spindle rodent Jaekyung fpass = [10,15]; dur>.5 & dur<2.5;

for i=1:size(eeg_new_diff,2)
    spindle {i} = detect_spindles( mat2cell(data.EEG(:,i), session_size, [1]),...
        'Fs',data.Fs_LFP,...
        'sleep_idx',mat2cell(data.sleep_idx, session_size, [1]),...
        'artifact_idx',mat2cell(data.artifact_idx, session_size, [1]),...
        'PLOT',1,...
        'sleep_classify',1);
end

% slow spindle some human adjustment fpass = [10,13]; dur>.3 & dur<2.0;
for i=1:size(eeg_new_diff,2)
    spindle_slow {i} = detect_spindles2_TG_slow( mat2cell(data.EEG(:,i), session_size, [1]),...
        'Fs',data.Fs_LFP,...
        'sleep_idx',mat2cell(data.sleep_idx, session_size, [1]),...
        'artifact_idx',mat2cell(data.artifact_idx, session_size, [1]),...
        'PLOT',1,...
        'sleep_classify',1);
end
% fast spindle some human adjustment fpass = [10,13]; dur>.3 & dur<2.0;
for i=1:size(eeg_new_diff,2)
    spindle_fast {i} = detect_spindles2_TG_fast( mat2cell(data.EEG(:,i), session_size, [1]),...
        'Fs',data.Fs_LFP,...
        'sleep_idx',mat2cell(data.sleep_idx, session_size, [1]),...
        'artifact_idx',mat2cell(data.artifact_idx, session_size, [1]),...
        'PLOT',1,...
        'sleep_classify',1);
end

clear i



%%save your newly created matrices

save([rootpath,'Analyzed SPINDLES_',eegfiles{3},'.mat'],'spindles','spindles_slow','spindles_fast','eeg_new' 'sleep_idx' 'artifact_idx')


%% count spindles

for i=1:size(eeg_new_diff,2)
    spindle_consol(1,i)=length(spindle{1,i}{1,1}.pks);
    spindle_consol(2,i)=length(spindle_slow{1,i}{1,1}.pks);
    spindle_consol(3,i)=length(spindle_fast{1,i}{1,1}.pks);
end

%plot as bars
y_1=spindle_consol(1,:);
y_1=y_1([1 2 3 4; 5 6 7 8]');

y_2=spindle_consol(2,:);
y_2=y_2([1 2 3 4; 5 6 7 8]');

y_3=spindle_consol(3,:);
y_3=y_3([1 2 3 4; 5 6 7 8]');

errY = zeros(4,2,2);
errY(:,:,1) = 0.0.*y;   % 10% lower error
errY(:,:,2) = 0.0.*y;   % 20% upper error

figure;
subplot(3,1,1)
barwitherr(errY, y_1);    % Plot with errorbars
set(gca,'XTickLabel',{'Frontal','Central','Parietal','Occipital'})
legend('Left','Right')
ylabel('No. of Spindles')
title ('All spindles (10-16 Hz)')

hold on;

subplot(3,1,2)
barwitherr(errY, y_2);    % Plot with errorbars
set(gca,'XTickLabel',{'Frontal','Central','Parietal','Occipital'})
legend('Left','Right')
ylabel('No. of Spindles')
title ('Slow spindles (10-13Hz)')

subplot(3,1,3)
barwitherr(errY, y_3);    % Plot with errorbars
set(gca,'XTickLabel',{'Frontal','Central','Parietal','Occipital'})
legend('Left','Right')
ylabel('No. of Spindles')
title ('Fast spindles (14-18Hz)')
hold off
    
    
    
    
    
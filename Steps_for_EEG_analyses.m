%% EEG analyses for spindles
% loads one patients data at a time
% Author: Rohit Ranwgani 
% Modifed version of code written by Aamir Abbasi and Tanuj Gulati

rootpath = 'D:/New_patient_data/EEG_data/'; % Change this path based on the location of the files in your computer

% List of patient eeg files
eegfiles =  { 'xxxxxx_14acb982-496f-4c83-9940-28c90449057c'...
    ,'xxxxxx_c2fbb91a-481e-407a-b1ad-81266f8691e5'...
    ,'xxxxxx_c6f109c9-6345-4cb3-855d-48e186fd27c9'...
    ,'xxxxxx_c9c68c96-575e-49c0-9563-6222e4a8144a'...
    ,'xxxxxx_fa652153-9360-44ff-8376-3e8486fc26e2'};

% EEG file to analyze
eegfile= eegfiles{5};

% Load data files with marked sleep epochs, etc.
load([rootpath,'DATA_w_SleepEpochsID_',eegfile,'.mat'])

% List of channels used for analysis
ChannelName = [ 'Left Frontal', "Left Central", "Left Parietal", "Left Occipital", "Right Frontal", "Right Central", "Right Parietal", "Right Occipital" ];

channels = size(ChannelName,2);


%% Run this to concatenate sleep epochs and create artificial sleep_idx and artifact_idx for further analyses.

[eeg_raw sleep_idx artifact_idx]=reconstruct_eeg(epochs, sleepepochs);

eeg_new = [];
artifact_idx_channels = [];

% Remove eeg artifacts
for i=1:22
    [eeg_new(:,i) artifact_idx_channels(:,i)]  = remove_artifact(eeg_raw(:,i),256);
end

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

Channels = [6, 7, 8, 5, 17, 18, 19, 16];

% artifact_idx_new = ones(size(eeg_new_diff));
% for i=1:8
%     artifact_idx_new(:,i) = artifact_idx_channels(:,Channels(i));
% end
% 
% artifact_idx_new = logical(artifact_idx_new);

%% detect spindles in the sample in all refrenced channels

data.EEG=eeg_new_diff;
session_size=size(data.EEG,1);
data.sleep_idx=sleep_idx;
data.artifact_idx=artifact_idx;
data.Fs_LFP=256;

% regular spindle rodent Jaekyung fpass = [10,15]; dur>.5 & dur<2.5;

% Find and plot spindles in [10 16], set plot to i for plotting
figure;
for i=1:channels
    spindle {i} = detect_spindles2_TG( mat2cell(data.EEG(:,i), session_size, [1]),...
        'Fs',data.Fs_LFP,...
        'sleep_idx',mat2cell(data.sleep_idx, session_size, [1]),...
        'artifact_idx',mat2cell( artifact_idx, session_size, [1]),...
        'fpass',[10,16],...
        'PLOT',i,... % Set PLOT to i, to use the index for subplot location
        'sleep_classify',1,...
        'ChannelName',ChannelName(i),...
        'DEBUG',0);
end
hold off;

% Find and plot slow spindles in [10 12], set plot to i for plotting
figure;
for i=1:channels
    % slow spindle some human adjustment fpass = [10,12]; dur>.3 & dur<2.0;
    spindle_slow {i} = detect_spindles2_TG( mat2cell(data.EEG(:,i), session_size, [1]),...
        'Fs',data.Fs_LFP,...
        'sleep_idx',mat2cell(data.sleep_idx, session_size, [1]),...
        'artifact_idx',mat2cell(data.artifact_idx, session_size, [1]),...
        'fpass',[10,12],...
        'PLOT',0,...
        'sleep_classify',1,...
        'DEBUG',0);
end
hold off;

% Find and plot fast spindles in [12 16], set plot to i for plotting
figure;
for i=1:channels
    % fast spindle some human adjustment fpass = [13,16]; dur>.3 & dur<2.0;
    spindle_fast {i} = detect_spindles2_TG( mat2cell(data.EEG(:,i), session_size, [1]),...
        'Fs',data.Fs_LFP,...
        'sleep_idx',mat2cell(data.sleep_idx, session_size, [1]),...
        'artifact_idx',mat2cell(data.artifact_idx, session_size, [1]),...
        'fpass',[13,16],...
        'PLOT',0,...
        'sleep_classify',1);
end
hold off;

% Find and plot so and delta in [0.1 4], set plot to i for plotting
figure;
for i=1:channels
    % detect so_delta in the dataset in all refrenced channels
    so_delta{i} = detect_so_delta(data.EEG(:,i),data.Fs_LFP,...
                'sleep_idx',data.sleep_idx,...
                'artifact_idx', artifact_idx,...
                'PLOT',i,...
                'mnl_parm',[85 40 .15 .5],...
                'ChannelName',ChannelName(i),...
                'DEBUG',0);
end
hold off;

clear i

%% save your newly created matrices with analyzed data
save([rootpath,'Analyzed SPINDLES_',eegfile,'.mat'],'spindle','spindle_slow','spindle_fast','eeg_new', 'sleep_idx', 'artifact_idx');



%% Find the count of nested Slow oscillaltions and spindles

% nested_consol  = ones(channels,);
for n=1:channels
    so_peak = so_delta{1,n}.so_down_states;
    spindle_peak = spindle_fast{1,n}{1,1}.pks ;
    nested = zeros(length(so_peak),1);
    for i=1:length(so_peak)
        count = 0;
        for j=1:length(spindle_peak)
           delay = spindle_peak(j)-so_peak(i);
           if(delay < 1.5 && delay > 0)
               count=count+1;
%                display(count);
           end
           if delay > 2
               break;
           end
        end
        nested(i) = count;
    end
    find_nested = find(nested);
    nested_consol(n) = length(find_nested);
end

%% count spindles and so and delta eeg signal

spindle_consol = ones(3,channels);

for i=1:channels
    spindle_consol(1,i)=length(spindle{1,i}{1,1}.pks);
%     display(spindle_consol(1,i));
    spindle_consol(2,i)=length(spindle_slow{1,i}{1,1}.pks);
%     display(spindle_consol(2,i));
    spindle_consol(3,i)=length(spindle_fast{1,i}{1,1}.pks);
%     display(spindle_consol(3,i));
    so_consol(i)=length(so_delta{1,i}.so_peaks);
%     fprintf('SO %d - %d\n',i, so_consol(i));
    delta_consol(i)=length(so_delta{1,i}.delta_peaks);
%     fprintf('Delta %d - %d\n',i, delta_consol(i));
end

SAMPLING_FREQUENCY = 256;
total_time = session_size/SAMPLING_FREQUENCY; %total signal duration in sec
total_time = total_time/60.0; %total time in min

%plot as bars

% error for all the counts
y_1=spindle_consol(1,:);
y_1=y_1([1 2 3 4; 5 6 7 8]');

y_2=spindle_consol(2,:);
y_2=y_2([1 2 3 4; 5 6 7 8]');

y_3=spindle_consol(3,:);
y_3=y_3([1 2 3 4; 5 6 7 8]');

y_4=so_consol;
y_4=y_4([1 2 3 4; 5 6 7 8]');

y_5=delta_consol;
y_5=y_5([1 2 3 4; 5 6 7 8]');

y_6=nested_consol;
y_6=y_6([1 2 3 4; 5 6 7 8]');

errY = zeros(4,2,2);

% errY(:,:,1) = 0.00.*y_1;   % lower error
% errY(:,:,2) = 0.00.*y_1;   % upper error

figure;
subplot(6,1,1)
barwitherr(errY, y_1/total_time);    % Plot with errorbars
set(gca,'XTickLabel',{'Frontal','Central','Parietal','Occipital'})
legend('Left','Right')
ylabel('Avg. spindle count per min')
title ('All spindles (10-16 Hz)')

hold on;

subplot(6,1,2)
barwitherr(errY, y_2/total_time);    % Plot with errorbars
set(gca,'XTickLabel',{'Frontal','Central','Parietal','Occipital'})
legend('Left','Right')
ylabel('Avg. spindle count per min')
title ('Slow spindles (10-12Hz)')

subplot(6,1,3)
barwitherr(errY, y_3/total_time);    % Plot with errorbars
set(gca,'XTickLabel',{'Frontal','Central','Parietal','Occipital'})
legend('Left','Right')
ylabel('Avg. spindle count per min')
title ('Fast spindles (13-16Hz)')

subplot(6,1,4)
barwitherr(errY, y_4/total_time);    % Plot with errorbars
set(gca,'XTickLabel',{'Frontal','Central','Parietal','Occipital'})
legend('Left','Right')
ylabel('Avg. SO count per minn')
title ('SO waves')

subplot(6,1,5)
barwitherr(errY, y_5/total_time);    % Plot with errorbars
set(gca,'XTickLabel',{'Frontal','Central','Parietal','Occipital'})
legend('Left','Right')
ylabel('Avg. delta count per min')
title ('Delta waves')
hold off

subplot(6,1,6)
barwitherr(errY, y_6/total_time);    % Plot with errorbars
set(gca,'XTickLabel',{'Frontal','Central','Parietal','Occipital'})
legend('Left','Right')
ylabel('Avg. nested(SO-spindles) count per min')
title ('Nested waves')
hold off

y_6 = y_6/total_time;

%% Plot Nested plot
figure;

scatter(y_6(1:4),y_6(5:8),25,'b');
xlim([0,2])
ylim([0,2])
xlabel('Left')
ylabel('Right')
refline(1,0);
% hold on;
% plot(y_6(5:8),'.','Markersize',20)
% hold off;

%% Plot raw eeg and filtered EEG (delta & spindle)

for i=1:channels 
    plot_eeg(data.EEG(:,i),256,ChannelName(i),[210,220])
end

%% Save all plot figures

% FolderName = rootpath;   % Your destination folder
% FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
% for iFig = 1:length(FigList)
%     FigHandle = FigList(iFig);
%     FigName   = num2str(get(FigHandle, 'Number'));
% %     FigName = datestr(now) + FigName;
%     set(0, 'CurrentFigure', FigHandle);
%     print(FigHandle,FigName,'-dpng','-r600');
% %   savefig(fullfile(FolderName, [FigName '.fig']));
% end
    
    
    
    
    
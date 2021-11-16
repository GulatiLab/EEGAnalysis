function plot_eeg(eegraw,Fs,ChannelName,time_sample)
%   Plot eeg and filtered bands
%
%   INPUTS:
%       eegraw - eegsignal
%       Fs - sampling frequency
%       ChannelName - name of channels for labelling the plots
%       time_sample - time period in sec. that you want to plot
%
%   OUTPUTS:
%       Plots of the raw signal and filtered spindles and delta/so band


%% Filter the EEG data
delta = filter_delta(eegraw,Fs,[.1,4]);
spindle = filter_spindle(eegraw,Fs,[10,16]);

time_sample = time_sample*Fs;
figure('Name',ChannelName(1));
subplot(4,1,1)
hold on;
time = (1:size(eegraw,1))'/Fs;
plot(time,mean(eegraw,2))
xlim([time(time_sample(1)),time(time_sample(2))])
% title(ChannelName(1))
xlabel('time (sec)')
ylabel('Raw EEG')
subplot(4,1,2)
time = (1:size(delta,1))'/Fs;
plot(time,mean(delta,2))
xlim([time(time_sample(1)),time(time_sample(2))])
% title(ChannelName(1))
xlabel('time (sec)')
ylabel('delta (0.1-4 Hz)')
subplot(4,1,3)
time = (1:size(spindle,1))'/Fs;
plot(time,mean(spindle,2))
xlim([time(time_sample(1)),time(time_sample(2))])
% title(ChannelName(1))
xlabel('time (sec)')
ylabel('spindle (10-16 Hz)')
subplot(4,1,4)
time = (1:size(spindle,1))'/Fs;
plot(time,mean((spindle+delta),2))
xlim([time(time_sample(1)),time(time_sample(2))])
xlabel('time (sec)')
ylabel('spindleZ+delta/so (10-16 Hz)')
hold off;

%% Filters the delta band
function eeg_delta = filter_delta(eeg,Fs,fpass)
    % filter for delta
    [b,a] = butter(2,fpass(1)/(Fs/2),'high');
    eeg_delta = filtfilt(b,a,eeg);
    % lowpass
    [b,a] = butter(4,fpass(2)/(Fs/2),'low');
    eeg_delta = filtfilt(b,a,eeg_delta);
end

%% Filters the spindles
function eeg_spindle = filter_spindle(eeg,Fs,fpass)
    % filter for spindle
    [b,a] = butter(6,fpass(1)/(Fs/2),'high');
    eeg_delta = filtfilt(b,a,eeg);
    % lowpass
    [b,a] = butter(8,fpass(2)/(Fs/2),'low');
    eeg_spindle = filtfilt(b,a,eeg_delta);
end


end
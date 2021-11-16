function [eeg artifact_idx] = remove_artifact(eeg,Fs)
%   Remove artifacts
%
%   INPUTS:
%       eeg - eeg signal
%       Fs - sampling frequency
%
%   OUTPUTS:
%       eeg = eeg signal after artifact removal
%       arifact_idx - indexes where artifacts were found


%% Thresold to filter the artifacts above that abs value
thresh = 20;

%% remove artifact (exceeds thresh)
idx = abs(eeg) > thresh;
idx = [0;idx;0];
up = find(diff(idx)==1);
dwn = find(diff(idx)==-1);
up = up - round(1*Fs);
dwn = dwn + round(1*Fs);
idx = [];

for i=1:length(up)
    idx = [idx,up(i):dwn(i)];
end
idx = unique(idx);
idx = idx(idx>0 & idx < length(eeg));

artifact_idx = zeros(1,length(eeg));
artifact_idx(idx) = 1;
artifact_idx = logical(artifact_idx);
not_artifact = ~artifact_idx;

% Reassign some values to eeg samples where artifacts were detected
eeg(diff(eeg)==0) = randn(sum(diff(eeg)==0),1)*std(eeg(not_artifact)) + mean(eeg(not_artifact)); %08/27/19 JK
eeg(artifact_idx) = randn(sum(artifact_idx),1)*std(eeg(not_artifact)) + mean(eeg(not_artifact)); %08/27/19 JK


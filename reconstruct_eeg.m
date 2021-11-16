function [eeg_new sleep_idx artifact_idx]=reconstruct_eeg(epochs, sleepepochs)
%   reconstruct eeg saamples using identified sleepepochs
%
%   INPUTS:
%       epochs - all epochs (No. of channels x Samples in a epoch x No. of epochs)
%       sleepepochs - indexs of epochs idetified with sleep
%
% 
%   OUTPUTS:
%       eeg_new - eeg samples reconstructed
%       sleep_idx - index of sleep samples (all ones, as it is all sleep epochs)
%       artifact_idx - index of artifcat samples (all zeros)
% 

tmp=[];
for i=1:size(epochs,3)
     if isempty(intersect(i,sleepepochs))== 1
        fprintf('%d is not sleep epoch!\n', i)
    else
        fprintf('%d is sleep epoch!\n', i)
        tmp = [tmp, epochs(:,:,i)];
    end
end
    eeg_new= double(tmp');
    sleep_idx = true(length(eeg_new),1);
    artifact_idx = false(length(eeg_new),1);
end
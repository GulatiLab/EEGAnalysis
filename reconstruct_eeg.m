function [eeg_new sleep_idx artifact_idx]=reconstruct_eeg(epochs, sleepepochs)

tmp=[]
for i=1:size(epochs,3)
    if isempty(intersect(i,sleepepochs))==1
        display (i)
        display ('is not sleep epoch')
    else
        display (i)
        display ('is a sleep epoch!!!')
        tmp= [tmp, epochs(:,:,i)];
    end
end
    eeg_new= double(tmp');
    sleep_idx =logical(ones(length(eeg_new),1));
    artifact_idx=logical(zeros(length(eeg_new),1));
end
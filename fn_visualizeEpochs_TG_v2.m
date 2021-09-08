<<<<<<< HEAD
function sleepepochs = fn_visualizeEpochs_TG_v2(eegepochs,badchans,title1)
%----------------------------------------------------------------------------
% Function to visualize raw EEG data and mark sleep epochs
% Author@ Aamir Abbasi
% INPUT -
%   -- trial_data: Collated LFP signals, output from fn_collateTrialData.m
%   -- badchans: Channel you want to remove (a 1d array).
% OUTPUT -
%   -- badtrials: A 1D array containing the id of bad trials.
%----------------------------------------------------------------------------

eegepochs(badchans,:,:)=[]; % remove bad chans
sz=size(eegepochs);
exit=0;
n=1;
sleepepochs=[];

fig=figure('units','normalized','outerposition',[0.1 0.1 .8 .8]);
e = squeeze(eegepochs(:,:,n));
for i=1:sz(1)
    plot(e(i,:)'+(100*i)); hold on;
end; hold off;
xlim([1 sz(2)]);
ylim([-100 2400]);
yticks(100:100:2200)
yticklabels({'Fp1 - F7','F7 - T3','T3 - T5','T5 - O1','Fp2 - F8','F8 - T4','T4 - T6','T6 - O2','A1 - T3','T3 - C3','C3 - Cz','Cz - C4','C4 - T4','T4 - A2','Fp1 - F3','F3 - C3','C3 - P3','P3 - O1','Fp2 - F4','F4 - C4','C4 - P4','P4 - O2'})
ax=gca;
ax.YGrid = 'on'; %ax.GridLineStyle = ':';
set(gca,'FontSize',16,'FontWeight','bold');
hold on;
uicontrol('style','text','string','Sleep Epochs','position',[50 50 80 20],'backgroundcolor',[.8 .8 .8]);
markerframes(1)=uicontrol('style','text','string','','HorizontalAlignment','left','position',[105,7,1394,40]);
hold off;

while ~exit
    title([title1 '---''Epoch ' num2str(n)])
    [~,~,button] = ginput(1);
    switch button
        case 32 % space
            if sum(sleepepochs == n)
                sleepepochs(sleepepochs==n)=[];
            else
                sleepepochs=[sleepepochs, n];
            end
            set(markerframes(1),'string',num2str(sleepepochs));
        case 28 % left
            n=n-1;
        case 29 % right
            n=n+1;
        case 101 % e to exit
            exit=1;
    end
    if n>sz(3)
        exit=1;
        continue
    end
    e = squeeze(eegepochs(:,:,n));
    for i=1:sz(1)
        plot(e(i,:)'+(100*i)); hold on;
    end; hold off;
    xlim([1 sz(2)]);
    ylim([-100 2400]);
    yticks(100:100:2200)
    yticklabels({'Fp1 - F7','F7 - T3','T3 - T5','T5 - O1','Fp2 - F8','F8 - T4','T4 - T6','T6 - O2','A1 - T3','T3 - C3','C3 - Cz','Cz - C4','C4 - T4','T4 - A2','Fp1 - F3','F3 - C3','C3 - P3','P3 - O1','Fp2 - F4','F4 - C4','C4 - P4','P4 - O2'})
    ax=gca;
ax.YGrid = 'on'; %ax.GridLineStyle = ':';
set(gca,'FontSize',16, 'FontWeight','bold');
end

=======
function sleepepochs = fn_visualizeEpochs_TG_v2(eegepochs,badchans,title1)
%----------------------------------------------------------------------------
% Function to visualize raw EEG data and mark sleep epochs
% Author@ Aamir Abbasi
% INPUT -
%   -- trial_data: Collated LFP signals, output from fn_collateTrialData.m
%   -- badchans: Channel you want to remove (a 1d array).
% OUTPUT -
%   -- badtrials: A 1D array containing the id of bad trials.
%----------------------------------------------------------------------------

eegepochs(badchans,:,:)=[]; % remove bad chans
sz=size(eegepochs);
exit=0;
n=1;
sleepepochs=[];

fig=figure('units','normalized','outerposition',[0.1 0.1 .8 .8]);
e = squeeze(eegepochs(:,:,n));
for i=1:sz(1)
    plot(e(i,:)'+(100*i)); hold on;
end; hold off;
xlim([1 sz(2)]);
ylim([-100 2400]);
yticks(100:100:2200)
yticklabels({'Fp1 - F7','F7 - T3','T3 - T5','T5 - O1','Fp2 - F8','F8 - T4','T4 - T6','T6 - O2','A1 - T3','T3 - C3','C3 - Cz','Cz - C4','C4 - T4','T4 - A2','Fp1 - F3','F3 - C3','C3 - P3','P3 - O1','Fp2 - F4','F4 - C4','C4 - P4','P4 - O2'})
ax=gca;
ax.YGrid = 'on'; %ax.GridLineStyle = ':';
set(gca,'FontSize',16,'FontWeight','bold');
hold on;
uicontrol('style','text','string','Sleep Epochs','position',[50 50 80 20],'backgroundcolor',[.8 .8 .8]);
markerframes(1)=uicontrol('style','text','string','','HorizontalAlignment','left','position',[105,7,1394,40]);
hold off;

while ~exit
    title([title1 '---''Epoch ' num2str(n)])
    [~,~,button] = ginput(1);
    switch button
        case 32 % space
            if sum(sleepepochs == n)
                sleepepochs(sleepepochs==n)=[];
            else
                sleepepochs=[sleepepochs, n];
            end
            set(markerframes(1),'string',num2str(sleepepochs));
        case 28 % left
            n=n-1;
        case 29 % right
            n=n+1;
        case 101 % e to exit
            exit=1;
    end
    if n>sz(3)
        exit=1;
        continue
    end
    e = squeeze(eegepochs(:,:,n));
    for i=1:sz(1)
        plot(e(i,:)'+(100*i)); hold on;
    end; hold off;
    xlim([1 sz(2)]);
    ylim([-100 2400]);
    yticks(100:100:2200)
    yticklabels({'Fp1 - F7','F7 - T3','T3 - T5','T5 - O1','Fp2 - F8','F8 - T4','T4 - T6','T6 - O2','A1 - T3','T3 - C3','C3 - Cz','Cz - C4','C4 - T4','T4 - A2','Fp1 - F3','F3 - C3','C3 - P3','P3 - O1','Fp2 - F4','F4 - C4','C4 - P4','P4 - O2'})
    ax=gca;
ax.YGrid = 'on'; %ax.GridLineStyle = ':';
set(gca,'FontSize',16, 'FontWeight','bold');
end

>>>>>>> 41b072826980b71cf10409a99e3b0a4392504288
close(fig);
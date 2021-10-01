function varargout = sleep_classification2(lfp,PLOT,varargin)
%% sleep_classification(lfp)
%   lfp should be a vector or matrix (samples x channels)
%   produces a plot of the lfp data where epochs are classified as sleep or
%   awake
%   classification is done by looking at the avg pwr in delta and gamma
%   bands (via hilbert method) then clustered using GMM
% 
% sleep_classification(lfp,PLOT,Fs)
%   Fs is the sample rate of lfp (default is 24414.0625 / 24)
% 
% sleep_classification(lfp,PLOT,Fs,win)
%   win is the size of the epochs in secs (default is 4 secs)
% 
% sleep_classification(lfp,PLOT,Fs,win,thresh)
%   thresh - removes "artifact" i.e., |signal| > thresh*std(signal)
% 
% sleep_idx = sleep_classification(lfp,...)
%   also returns indices 
%       1 = sleep
%       0 = awake
% 
% [sleep_idx,artifact_idx] = sleep_classification(lfp,...)
%   also returns indices of LFP above threshold (assumed artifact)
%       1 = sleep
%       0 = awake
% 
% [sleep_idx,artifact_idx,pwr] = sleep_classification(lfp,...)
%   also returns power of LFP for each idx
%   [delta_sleep,gamma_sleep]
%   [delta_awake,gamma_awake]
% 


%% deal with inputs
narginchk(2,5)
if nargin==1,
    PLOT=1;
    Fs = 24414.0625 / 24;
    window = 4;
    thresh = 10;
elseif nargin==2,
    Fs = 24414.0625 / 24;
    window = 4;
    thresh = 10;
elseif nargin==3,
    Fs = varargin{1};
    window = 4;
    thresh = 10;
elseif nargin==4,
    Fs = varargin{1};
    window = varargin{2};
    thresh = 10;
elseif nargin==5,
    Fs = varargin{1};
    window = varargin{2};
    thresh = varargin{3};
end

if ~ismatrix(lfp),
    error('lfp should be a vector or matrix (samples x channels)')
end
if ~isscalar(Fs),
    error('Fs should be a scaler')
end
if ~isscalar(window),
    error('win should be a scaler')
end

%% sizing info
samples = round(Fs * window);
N = size(lfp,1) - mod(size(lfp,1),samples);
rows = samples;
cols = N/rows;
T = N/samples;


%% zscore lfp so that channels are comparable and remove any nans
lfp = zscore(lfp);
lfp = mean(lfp(:,~isnan(lfp(1,:))),2);

%% remove artifact (exceeds X std)
idx = abs(lfp) > thresh;
idx = [0;idx;0];
up = find(diff(idx)==1);
dwn = find(diff(idx)==-1);
up = up - round(1*Fs);
dwn = dwn + round(1*Fs);
idx = [];
for i=1:length(up),
    idx = [idx,up(i):dwn(i)];
end
idx = unique(idx);
idx = idx(idx>0 & idx < length(lfp));

artifact_idx = zeros(1,length(lfp));
artifact_idx(idx) = 1;
artifact_idx = logical(artifact_idx);
not_artifact = ~artifact_idx;
lfp(diff(lfp)==0) = randn(sum(diff(lfp)==0),1)*std(lfp(not_artifact)) + mean(lfp(not_artifact)); %08/27/19 JK
lfp(artifact_idx) = randn(sum(artifact_idx),1)*std(lfp(not_artifact)) + mean(lfp(not_artifact)); %08/27/19 JK
% lfp(artifact_idx) = mean(lfp(not_artifact));

%% get pwr in delta and gamma bands
% frequency bands
fpass = {
    [.5,4]  % delta
    [40,70] % gamma
    };

idx = 1:samples;
pwr = zeros(T,length(fpass)); %dims: epochs x 2(delta, gamma)
for i=1:T,
    [Pxx,F] = pwelch(lfp(idx,:),[],[],2^nextpow2(samples),Fs);
    for j=1:length(fpass),
        fidx = F>=fpass{j}(1) & F<=fpass{j}(2);
        pwr(i,j) = mean(mean(10*log10(Pxx(fidx,:))));                       %wht 10log10 ?
%         pwr2(i,j) = mean(mean(Pxx(fidx,:)));
    end
    idx = idx + samples;
end

%% do gaussian mixture model to get indices of sleep
% obj = fitgmdist(pwr,2);
% ctr = obj.mu;
% idx = cluster(obj,pwr);
rng('default');
[idx, ctr] = kmeans(pwr, 2, 'start', 'plus','Replicates',10); %sample

if ctr(1,1)>ctr(2,1), % higher delta power = sleep
    sleep_idx = idx==1;
else
    sleep_idx = idx==2;
end

%% average pwr
pwr_out = mean(pwr( sleep_idx,:),1);
pwr_out = cat(1,pwr_out,mean(pwr(~sleep_idx,:),1));

%% must have at least 60sec in a row to count as sleep
Nwin = floor(30 / window);
tmp = cat(1,0,sleep_idx);
upidx = find(diff(tmp)==1);
tmp = cat(1,sleep_idx,0);
dwnidx = find(diff(tmp)==-1);
lgt = dwnidx - upidx + 1;
lgt60 = lgt>=Nwin;
sleep_idx = zeros(size(sleep_idx));
for i=1:length(lgt60),
    if lgt60(i),
        sleep_idx(upidx(i):dwnidx(i)) = 1;
    end
end
sleep_idx = logical(sleep_idx);
% idx0 = 2:length(tmp)-1;
% idx_1 = idx0 - 1;
% idx1 = idx0 + 1;
% sleep_idx = tmp(idx0)==1 & (...
%     (tmp(idx_1)==1)  | ...
%     (tmp(idx1)==1)   );

% %% must have at least 2 awake epochs in a row to count as awake
% awake_idx = ~sleep_idx;
% tmp = cat(1,awake_idx,0);
% tmp = cat(1,0,tmp);
% idx0 = 2:length(tmp)-1;
% idx_1 = idx0 - 1;
% idx1 = idx0 + 1;
% 
% awake_idx = tmp(idx0)==1 & (...
%     (tmp(idx_1)==1)  | ...
%     (tmp(idx1)==1)   );
% sleep_idx = ~awake_idx;

%% plot
if PLOT==1
    figure;
    cc = get(gca,'ColorOrder');
    set(gcf,'Position',[380 333 560 645]);
    subplot(3,1,1:2)
    scatter(pwr(~sleep_idx,1),pwr(~sleep_idx,2),1,cc(1,:),'o'), hold on
    scatter(pwr( sleep_idx,1),pwr( sleep_idx,2),1,cc(2,:),'+'), hold on
    legend('awake','sleep')
    xlabel('Delta Power of Z-Scored LFP')
    ylabel('Gamma Power of Z-Scored LFP')
end

%% sleep_idx per window to sleep_idx per lfp index
sleep_idx = repmat(sleep_idx(:),1,samples);
sleep_idx = reshape(sleep_idx',T*samples,1);
sleep_idx = [sleep_idx;zeros(size(lfp,1)-size(sleep_idx,1),1)];
sleep_idx = sleep_idx==1;

%% plot in time domain
if PLOT==1
    time = (1:size(lfp,1))'/Fs/60;
    subplot(3,1,3), hold on
    plot(time,mean(lfp,2))
    plot(time(sleep_idx),mean(lfp(sleep_idx,:),2),'.')
    xlim([time(1),time(end)])
    xlabel('time (min)')
    ylabel('mean z-scored lfp')
end

%% output
if nargout>0,
    varargout{1} = sleep_idx;
end
if nargout>1,
    varargout{2} = artifact_idx';
end
if nargout>2,
    varargout{3} = pwr_out;
end



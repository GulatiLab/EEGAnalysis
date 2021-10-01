% Kim et al., Cell, 2019 - spindle detection code
clear; close all;

load('example_data.mat'); %load example data
data

% detection of slow-oscillations and delta-waves
% you need to input -   LFP and sampling frequency
%                       logicals or binary index of NREM sleep detection (you would have your detections for your data)
%                       logicals or binary index of artifact detection. you may set it zeros to ignore it
%                       plotting results
%                       parameters for [peak-thr trough-thr dur-min dur-max]
%                       using only sleep period
        
session_size=size(data.LFP,1);        
spindle = detect_spindles( mat2cell(data.LFP, session_size, [1]),...
    'Fs',data.Fs_LFP,...
    'sleep_idx',mat2cell(data.sleep_idx, session_size, [1]),...
    'artifact_idx',mat2cell(data.artifact_idx, session_size, [1]),...
    'PLOT',1,...
    'sleep_classify',1);        
videoFile = 'exclude/MGhand_MoveAlgorithms-540p.mp4';
resizeFactor = 0.25; % smaller  = faster
ROItimestamp = 5; % this is the frame where you select ROI

fpass = [0.5 10]; % use: [min > 0, max < Fs / 2]
numfreqs = 30; % less frequencies to analyze = faster processing
freqList = linspace(fpass(1),fpass(2),numfreqs);

[allFrames,pos] = videoFreqAnalysis(videoFile,resizeFactor,ROItimestamp,freqList);
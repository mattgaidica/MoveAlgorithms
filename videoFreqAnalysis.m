function [allFrames,pos] = videoFreqAnalysis(videoFile,resizeFactor,ROItimestamp,freqList)
% Converts changes in pixel values to frequency domain
%
%
% Inputs:
%    videoFile - path to [MATLAB compatible format] video
%    resizeFactor - resizes the video frames to hasten analysis
%    ROItimestamp - timestamp used to draw ROI
%    freqList - frequencies to use in analysis
%
% Outputs:
%    allFrames - all frames (grayscale) used in analysis (cropped by ROI)
%    pos - ROI rectangle position
%
% Example: 
%       see: test_videoFreqAnalysis.m
%
% Other m-files required: none
% Subfunctions: none

% Author: Matt Gaidica, PhD Candidate
% University of Michigan
% email address: matt@gaidi.ca
% Website: http://gaidi.ca

%------------- BEGIN CODE --------------

dodebug = false; % shows frames being analyzed

v = VideoReader(videoFile);
% get frame to set ROI
v.CurrentTime = ROItimestamp;
frame = readFrame(v);
v.CurrentTime = 0;
% re-read video at t = 0
v = VideoReader(videoFile);

% prompt user for ROI
frame = imresize(frame,resizeFactor);
h = figure;
imshow(frame);
hrect = imrect;
pos = getPosition(hrect);
close(h);

% build a matrix with all video frames
allFrames = [];
ii = 1;
if dodebug
    h = figure;
end
hw = waitbar(0,'Analyzing video...');
while hasFrame(v)
    waitbar(v.CurrentTime/v.Duration);
    frame = readFrame(v);
    frame = imresize(frame,resizeFactor);
    frame = imcrop(frame,pos);
    frameGray = imadjust(rgb2gray(frame),[0.1 0.8]);
    if dodebug
        imshow(frameGray);
    end
    allFrames(ii,:,:) = frameGray;
    ii = ii + 1;
end
close(hw);
if dodebug
    close(h);
end

% format as numSamples x numTrials (where samples = frames, trials = vectorized images)
data = squeeze(reshape(allFrames,[size(allFrames,1) 1 size(allFrames,2)*size(allFrames,3)]));
% the idea here is to only analyze pixels that move a lot and ignore
% stationary ones; may not be needed if the ROI contains a lot of movement
dataStd = std(data);
dataAdj = data(:,dataStd > prctile(dataStd,80));

Fs = round(v.FrameRate); % frame rate is sampling frequency
% 'FrequencyLimits',FLIMS
[P,F,T] = pspectrum(dataAdj,Fs,'spectrogram');
% [W,freqList,t] = calculateComplexScalograms(dataAdj,'Fs',Fs,'freqList',freqList,'doplot',false);
% realW = squeeze(mean(abs(W).^2,2))';

figure;
subplot(211);
imagesc(T,F,P);
set(gca,'YDir','normal');
xlim([t(1)+0.5 t(end)-0.5]);
colormap(jet);
xlabel('Time (s)');
ylabel('Freq (Hz)');
title('Frequency Domain Analysis');
% caxis([0 200]);
colorbar;
set(gca,'fontSize',16);
% 
% subplot(212);
% plot(freqList,mean(realW,2));
% xlim([min(freqList) max(freqList)]);
% xlabel('Freq (Hz)');
% ylabel('Amplitude (arb. units)');
% set(gca,'fontSize',16);

set(gcf,'color','white');
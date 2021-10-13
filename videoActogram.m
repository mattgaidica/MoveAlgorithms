function frameData = videoActogram(videoFile,frameInterval,resizePx)
% Quantifies changes in pixel values from a video; a surrogate Actogram.
%
%
% Inputs:
%    videoFile - path to [MATLAB compatible format] video
%    frameInterval - skip frames; speed execution by setting this > 1
%    resizePx - resize the video to this pixel size; smaller = faster
%
% Outputs:
%    frameData - m x n matrix where m = frame number, ...
%       n(1) = frame being analyzed
%       n(2) = frame timestamp (in seconds)
%       n(3) = mean change in pixel values from previous frame
%
% Example: 
%       see: tests/test_videoActogram.m
%
% Other m-files required: none
% Subfunctions: none

% Author: Matt Gaidica, PhD Candidate
% University of Michigan
% email address: matt@gaidi.ca
% Website: http://gaidi.ca

%------------- BEGIN CODE --------------

frameData = [];
v = VideoReader(videoFile);

allFrames = [];
iFrame = 1;
ii = 0;
prevFrame = [];
h = waitbar(0,'Processing actogram...');
while hasFrame(v)
    frame = readFrame(v);
    if mod(ii,frameInterval) ~= 0
        ii = ii + 1;
        continue;
    end
    waitbar(v.CurrentTime/v.Duration,h);
    frame = imresize(frame,[resizePx NaN]);
%     frame = imcrop(frame,pos);
    frame = rgb2gray(frame);
%     imshow(frame);
    allFrames(iFrame,:,:) = frame;
    frameData(iFrame,1) = ii + 1;
    frameData(iFrame,2) = ii / v.FrameRate;
    frameData(iFrame,3) = 0;
    if ~isempty(prevFrame)
        frameData(iFrame,3) = abs(mean2(frame - prevFrame));
    end
    
    prevFrame = frame;
    iFrame = iFrame + 1;
    ii = ii + 1;
end
close(h);
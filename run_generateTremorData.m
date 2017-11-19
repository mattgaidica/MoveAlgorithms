% subject = '6152';
% videoFile = ['/Users/mattgaidica/Documents/Data/Videos for Tremor Analysis/edits/',subject,'.mov'];

% videoFile = '/Users/mattgaidica/Dropbox/Projects/Dauer Lab/Mouse Tremor/6415-small-clip.mp4';
% videoFile = '/Users/mattgaidica/Dropbox/Projects/Dauer Lab/Mouse Tremor/6413-green.mov';
videoFile = '/Users/mattgaidica/Desktop/R0201_072617_20mW_20Hz_cutMG.mp4';
subject = 'R0201_072617_20mW_20Hz_cutMG';
v = VideoReader(videoFile);
resizeScale = 0.5;

v.CurrentTime = 0.5;
frame = readFrame(v);
v.CurrentTime = 0;

frame = imresize(frame,resizeScale);
h1 = figure;
imshow(frame);
h = imrect;
pos = getPosition(h);
close(h1);

v = VideoReader(videoFile);

allFrames = [];
ii = 1;
h1 = figure;
h = waitbar(0,'Analyzing video...');
while hasFrame(v)
    waitbar(v.CurrentTime/v.Duration);
    frame = readFrame(v);
    frame = imresize(frame,resizeScale);
    frame = imcrop(frame,pos);
    frameGray = imadjust(rgb2gray(frame),[0.1 0.8]);
    imshow(frameGray);
    allFrames(ii,:,:) = frameGray;
    ii = ii + 1;
end
close(h);
close(h1);

% imshow(frame);
% h = imrect;
% pos = getPosition(h);

Fs = round(v.FrameRate);
if Fs < 60
    fpass = [0 10]; % this could really help clean up the data/artifacts
end

% format as numSamples x numTrials (where samples = frames, trials = vectorized images)
data = squeeze(reshape(allFrames,[size(allFrames,1) 1 size(allFrames,2)*size(allFrames,3)]));
% the idea here is to only analyze pixels that move a lot and ignore
% stationary ones, but with selecting ROI, this might only be useful to
% reduce processing load and not entirely helpful as it ignores small
% movements that might be important
dataStd = std(data);
dataAdj = data(:,dataStd > prctile(dataStd,80));

[W,freqList,t] = calculateComplexScalograms_EnMasse(dataAdj,'Fs',Fs,'fpass',fpass,'doplot',false);
realW = squeeze(mean(abs(W).^2, 2))';

figure;
subplot(211);
imagesc(t,freqList,realW);
set(gca, 'YDir', 'normal');
xlim([t(1)+0.5 t(end)-0.5]);
colormap(jet);
xlabel('Time (s)');
ylabel('Freq (Hz)');
title(subject);
caxis([0 200]);
colorbar;

subplot(212);
plot(freqList,mean(realW,2));
xlim(fpass);
xlabel('Freq (Hz)');
ylabel('Amplitude (arb. units)');
ylim([0 150]);

set(gcf,'color','white');

% h = imfreehand;
% mask = createMask(h);
% close(hfig);
% 
% frameMasked = frameGray .* uint8(mask);
% imshow(frameMasked);
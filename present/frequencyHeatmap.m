% view heatmap
v = VideoReader(videoFile);
Fs = round(v.FrameRate);
frameInterval = 5; % skips analyzing frames

heatmapFrames = tremorHeatmap(allFrames,freqList,Fs,frameInterval);

[pathstr,name,ext] = fileparts(videoFile);
processedPath = fullfile(pathstr,[name,'_heatmap']);
vout = VideoWriter(processedPath,'MPEG-4');
vout.Quality = 95;
open(vout);

h = figure('position',[0 0 800 800]);
curFrame = 1;
while hasFrame(v)
    frame = readFrame(v);
    subplot(211);
    imshow(frame);
    hold on;
    rectangle('Position',pos/resizeFactor,'EdgeColor','r','lineWidth',4);
    hold off;
    
    subplot(212);
    imagesc(squeeze(heatmapFrames(curFrame,:,:)));
    colormap(jet);
    title('Compressed ROI');
    set(gca,'fontSize',16);
    
    fullframe = getframe(h);
    writeVideo(vout,fullframe);
    curFrame = curFrame + 1;
end
close(vout);
close(h);
function heatmapFrames = tremorHeatmap(allFrames,freqList,Fs,frameInterval)

frameBins = Fs; % frames
heatmapFrames = [];
zeromap = zeros(size(allFrames,2),size(allFrames,3));
heatmap = zeromap;
h = waitbar(0,'Creating heatmap...');
for iFrame = 1:size(allFrames,1)
    waitbar(iFrame/size(allFrames,1));
    if iFrame > frameBins && iFrame + frameBins < size(allFrames,1)
        if mod(iFrame,frameInterval) == 0
            binFrames = allFrames(iFrame-frameBins:iFrame+frameBins-1,:,:);
            data = squeeze(reshape(binFrames,[size(binFrames,1) 1 size(binFrames,2)*size(binFrames,3)]));
            [W,freqList,t] = calculateComplexScalograms(data,'Fs',Fs,'freqList',freqList,'doplot',false);
            heatmap = mean(mean(abs(W).^2),3);
            heatmap = reshape(heatmap,[size(binFrames,2) size(binFrames,3)]);
        end
        heatmapFrames(iFrame,:,:) = heatmap;
    else
        heatmapFrames(iFrame,:,:) = zeromap;
    end
    iFrame = iFrame + 1;
end
close(h);
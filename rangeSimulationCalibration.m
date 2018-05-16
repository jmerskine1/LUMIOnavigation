clear all
% load big data
%import topographical Moon surface
[Moon,R] = geotiffread('ulcn2005_lpo_dd0.tif');

initialDistance = 20000;
finalDistance = 60000;
distanceIncrement = 1000;
incrementNumber = (finalDistance - initialDistance)/distanceIncrement;

%RangeSimulation
illuminationAngle = 1;

%Moon Geometry info
MoonRadius = 1737.1e3;   %km
%distanceToMoon = 30e3; %km 


%%
%Compression code
compressionRatio = 16;
height = size(Moon,1);
width = size(Moon,2);

RComp = R;
RComp.RasterSize = (R.RasterSize)/compressionRatio;

compressedHeight = height/compressionRatio;
compressedWidth = width/compressionRatio;
MoonComp = zeros(compressedHeight,compressedWidth);

%Average every 16 square data points into one data point
for i = 1:compressedHeight
    for j = 1:compressedWidth
        heightRange = [((i-1)*compressionRatio)+1,i*compressionRatio];
        widthRange = [((j-1)*compressionRatio)+1,j*compressionRatio];
        MoonCompArray = Moon(heightRange(1):heightRange(2),widthRange(1):widthRange(2));
        MoonComp(i,j) = (sum(sum(MoonCompArray)))/(compressionRatio^2);
    end
end
%Compression Done

emphasiseTexture = 1; %Set to 1 = no emphasis
MoonComp = (MoonComp/MoonRadius)*emphasiseTexture;


outvid=VideoWriter(['/Users/Jonny/Documents/Delft/Microsat_Engineering/movies/', 'rangeCycle']);
%%
FSize = incrementNumber;
distanceCycle(FSize) = struct('cdata',[],'colormap',[]);
data = zeros(incrementNumber,3);
predictedDistance = zeros(incrementNumber,1);

% Pan sunlight accross moon
open(outvid);
for increment = 1:incrementNumber
    distanceToMoon = initialDistance + (distanceIncrement * (increment - 1));
    distanceToMoon = (distanceToMoon*(10^3))/MoonRadius; %moon radii

    [imageName, F] = moonViewModuleCalibration(distanceToMoon, illuminationAngle, MoonComp, RComp);
    frame = F;
    distanceCycle(i) = F;
    writeVideo(outvid,frame);
    data(increment,:) = MoonDetect(imageName,-180,'circle');
    close all
    distanceToMoon
    predictedDistance(increment) = AutoNav(0,data(increment,1),[data(increment,2),data(increment,3)])
    increment
end

close(outvid);
%%


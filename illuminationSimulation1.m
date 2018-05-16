clear all
% load big data
%import topographical Moon surface
[Moon,R] = geotiffread('ulcn2005_lpo_dd0.tif');

initialIllumination = 1; %set illumination limits
finalIllumination = 180;

%Moon Geometry info
MoonRadius = 1737e3;   %km
distanceTrue = 27e3; %km 
distanceToMoon = (distanceTrue*(10^3))/MoonRadius; %moon radii


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
for increment = 1:compressedHeight
    for j = 1:compressedWidth
        heightRange = [((increment-1)*compressionRatio)+1,increment*compressionRatio];
        widthRange = [((j-1)*compressionRatio)+1,j*compressionRatio];
        MoonCompArray = Moon(heightRange(1):heightRange(2),widthRange(1):widthRange(2));
        MoonComp(increment,j) = (sum(sum(MoonCompArray)))/(compressionRatio^2);
    end
end
%Compression Done

emphasiseTexture = 1; %Set to 1 = no emphasis
MoonComp = (MoonComp/MoonRadius)*emphasiseTexture;


outvid=VideoWriter(['/Users/Jonny/Documents/Delft/Microsat_Engineering/movies/', 'illuminatedLunarCycle']);
%%
FSize = (finalIllumination - initialIllumination)
illuminatedLunarCycle(FSize) = struct('cdata',[],'colormap',[]);
distance = zeros(FSize,1);
predictedDistance = zeros(FSize,1);
% Pan sunlight accross moon
open(outvid);
for illuminationAngle = initialIllumination:finalIllumination 
    increment = (illuminationAngle + 1) - initialIllumination;
    distance(increment) = distanceTrue;
    [imageName, F] = moonViewModule(distanceToMoon, illuminationAngle, MoonComp, RComp);
    %distanceToMoon = (distanceToMoon*(10^3))/MoonRadius;
    frame = F;
    illuminatedLunarCycle(increment) = F;
    writeVideo(outvid,frame);
    %data = MoonDetect(imageName,-180,'circle');
    close all
    distanceCycle(increment) = F;
    writeVideo(outvid,F);
    %threshold = (0.1 - (illuminationAngle/1800));
    data(increment,:) = MoonDetect(imageName,-180,'circle','illumination',illuminationAngle,distance);
    close all
    predictedDistance(increment) = AutoNav(0,data(increment,1),[data(increment,2),data(increment,3)]);
    error(increment) = 100 - ((distance(increment)/predictedDistance(increment))*100);
    increment
    illuminationAngle
end

close(outvid);
%%


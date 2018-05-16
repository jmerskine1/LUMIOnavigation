
function [imageName, F] = moonViewModule(distanceToMoon, illuminationAngle, MoonComp, RComp)
%Simulates Size and Illumination of Moon for given range and sun angle

%%
%Inputs             type    units
%-----------------  ------  -----
%   distanceToMoon; double; km
%   illumination;   int;    degrees

%%
%Outputs            type    units
%-----------------  ------  -----
%   imageName;      string;  - 

%%

MoonRadius = 1737e3;  
DarkMoon = MoonComp;
%calibrationFactor1 = 5.9;
%calibrationFactor2 = 0.5;
%calibrationFactor3 = 0.8755;
calibrationFactor1 = 5.9;
calibrationFactor2 = 0.5;
calibrationFactor3 = 0.8755;
distance = calibrationFactor1+((distanceToMoon^calibrationFactor3)*calibrationFactor2);
%Simulating Darkness

if illuminationAngle >= 1 && illuminationAngle <= 90
    %longitudinal settings
    longitudinalViewCorrection = 90;        %degrees
    darkLongSegment = illuminationAngle;    %degrees

    %lateral setting
    lateralViewCorrection = 0;          %degrees
    darkLatSegment = 180;               %degrees

    
    DarkMoon(lateralViewCorrection+1:darkLatSegment,...
                    270:(270+illuminationAngle)) = 0; %Flatten dark sectors
    baseR = georefcells([(-90 + lateralViewCorrection)... 
                         (90 - lateralViewCorrection)],...
                         [longitudinalViewCorrection 
                         (darkLongSegment+longitudinalViewCorrection)],...
                         size(DarkMoon)); %Define limits of dark sector
                     %%

 
else if illuminationAngle >= 91 && illuminationAngle <= 180
    longitudinalViewCorrection = 90;        %degrees
    darkLongSegment = illuminationAngle;    %degrees

    %lateral setting
    lateralViewCorrection = 0;          %degrees
    darkLatSegment = 180;               %degrees

    DarkMoon(lateralViewCorrection+1:darkLatSegment,270:360) = 0; %Flatten dark sectors

    DarkMoon(lateralViewCorrection+1:darkLatSegment,...
               1:(darkLongSegment-longitudinalViewCorrection)) = 0; %Flatten dark sectors
    baseR = georefcells([(-90 + lateralViewCorrection)... 
                         (90 - lateralViewCorrection)],...
                         [longitudinalViewCorrection 
                         (darkLongSegment+longitudinalViewCorrection)],...
                         size(DarkMoon)); %Define limits of dark sector
    %baseR2 = georefcells([(-90 + lateralViewCorrection)... 
                         %(90 - lateralViewCorrection)],...
                         %[0 (darkLongSegment-longitudinalViewCorrection)],...
                         %size(DarkMoon)); %Define limits of dark sector
                     %%
 
    else
        error_message = 'Illumination angle outof bounds: Must be between 1:180'
    end
end

%initialise figure
figure
hold on
colormap(gray)
axesm('globe','galt',0);                    % Set global axis
set(gcf,'color','black');                   % Black background
material(0.1*[ 1 1 1]);                     % Reflectivity
plat = 180; plon = 0;                       % Camera orientation
tlat = 180; tlon = 0;                       % Target position
camtargm(tlat,tlon,0);                      % Set target
camposm(plat,plon,distance);          % Set camera
set(gca,'CameraViewAngle',distance)   % Set distance to target
axis off

blackColor = [0.0 0.0 0.0];
%camlight(illuminationAngle,0);
FaceLighting = 'flat';
AmbientStrength = 0.9;
%DiffuseStrength = 0.;
SpecularStrength = 0.1;


%SpecularExponent = 1;
hs = meshm(DarkMoon,RComp,size(DarkMoon),DarkMoon); % Plot flattened area
hs = geoshow(DarkMoon, baseR, 'FaceColor', blackColor); %Color flattened


fig = gcf;
fig.InvertHardcopy = 'off';        % Prevents reverting of bg to white
format shortG
distanceName = ((distanceToMoon*MoonRadius)/(10^3));
imName1 = 'test_';
imName2 = num2str(distanceName,0);
imName3 = '_km.png';
imageName = strcat(imName1,imName2,imName3);
saveas(gcf,imageName) % Save figure
F = getframe(gcf);
%J = imresize(F, [1024, 1024], 'bicubic');

%%
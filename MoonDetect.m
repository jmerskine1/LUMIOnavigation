%%% Celestial Object Radius and Centroid Detection

function FitData = MoonDetect(moon,sunangle,fitset,simulationType,illuminationAngle,distance)
%% Input
    %moon = image of (partially lit and/or partial) moon .jpg
    %sunangle = direction of sunlight measured CCW from positive x axis (so
    %sunlight GOING to the right is 0)
    %fitset = either 'ellipse' or 'circle' to determine what it should try to fit

%% Output
    % FitData = [a, b, X0, Y0] for 'ellipse'
        % a = semi-major axis
        % b = semi-minor axis
        % X0, Y0 = centre of ellipse coordinates (in original image)
    % FitData = [r, X0, Y0] for 'circle'
        % r = circle radius
        % X0, Y0 = centre of circle coordinates (in original image)
    % FitData = [] if neither circle or ellipse is selected
    
    
    
%% Reading Inputs
% Reading Image
testmoon = imread(moon);
Sunangle = sunangle; % Measured CCW from negative x axis (decreasing column indices)

%% Object Segmentation Morphology
% Converting to Greyscale
greymoon = rgb2gray(testmoon);
% Converting to binary map
if strcmp(simulationType,'illumination')
    if illuminationAngle < 90
        threshold = 0.1;
        binmoon = imbinarize(greymoon, threshold);
    elseif illuminationAngle > 90
        binmoon = imbinarize(greymoon);
    else
        binmoon = imbinarize(greymoon);
    end
elseif strcmp(simulationType,'distance')
        if distance < 40000
        threshold = 0.1;
        binmoon = imbinarize(greymoon,threshold);
    elseif distance > 40000
        binmoon = imbinarize(greymoon);
    else
        binmoon = imbinarize(greymoon);
        end
else
    error = "specify simulation type: (1) `distance` or (2) `illumination`"
end

    

% Defining Structuring Element for Dilation and Erosion
SEr = 4;
SE = strel('disk', SEr);
% Dilation and Erosion (Opening Image)
openmoon = imopen(binmoon, SE);

%% Detecting Object Size
[openrows, opencolumns] = size(openmoon);
margin = 10; %pixels
% Detecting Upper Y edge
i = 1;
j = 1;
while openmoon(i,j)==0
    j = j + 1;
    if j == opencolumns
        j = 1;
        i = i + 1;
    end
end
Yup = i - margin;

% Detecting Lower Y Edge
j = 1;
i = openrows;
while openmoon(i,j)== 0
    j = j + 1;
    if j == opencolumns
        j = 1;
        i = i - 1;
    end
end
Ylow = i + margin;

% Detecting Upper X edge
j = 1;
i = 1;
while openmoon(i,j)== 0
    i = i + 1;
    if i == openrows
        i = 1;
        j = j + 1;
    end
end
Xup = j - margin;

% Detecting Lower X edge
j = opencolumns;
i = 1;
while openmoon(i,j)== 0
    i = i + 1;
    if i == openrows
        i = 1;
        j = j - 1;
    end
end
Xlow = j + margin;

%% Segmenting Object Block From Image
width = Xlow - Xup;
height = Ylow - Yup;
moon = imcrop(openmoon, [Xup Yup width height]);

%% Edge Detection
edgemoon = edge(moon, 'Prewitt');

%% Pseudo Edge Removal Using Sun Direction
%Getting Gradient
[~, EdgeGrad] = imgradient(moon,'Prewitt');
EdgeGradIm = EdgeGrad;

% Ensuring 0 angles are not filtered out later
[moonrows, mooncols] = size(moon);
for i = 1:moonrows
    for j = 1:mooncols
        if edgemoon(i,j)== 0
            EdgeGrad(i,j)= NaN;
        end
    end
end

% Defining sunlit semicircle edges in -180 to 180 degrees space 
LowSun = -90+ Sunangle;
UpSun = 90 + Sunangle;
if LowSun < -180
    LowSun = LowSun + 360;
end

if UpSun > 180
    UpSun = UpSun - 360;
end

% Turning edge gradient into binary mask
BinMask = EdgeGrad;
if UpSun > LowSun
    BinMask(BinMask<UpSun & BinMask>LowSun)=1;
elseif UpSun < LowSun
    BinMask(BinMask>LowSun & BinMask<=180)=1;
    BinMask(BinMask<UpSun & BinMask>=-180)=1;
end
BinMask(BinMask~=1)=0;

%Removing remaining small pixel groups from BinMask
PixThreshold = 100;
BinMask = bwareaopen(BinMask,PixThreshold);

figure 
imshowpair(BinMask,EdgeGradIm,'montage')
title('BinaryMask and Edge Gradient')

%Overlaying BinMask over EdgeDetection to form final dta 
[dorows, docols]= size(BinMask);
finalmoon = zeros(moonrows, mooncols);
for i = 1:dorows
    for j = 1:docols
        if BinMask(i,j)==1 && edgemoon(i,j)==1
            finalmoon(i,j)= 1;
            
        end
    end
end

% Turning Binary Image Data to x,y-data
xlist = [];
ylist = [];
[firows, ficols] = size(finalmoon);
for i = 1:firows
    for j = 1:ficols
        if finalmoon(i,j)==1
            ylist = [ylist; i];
            xlist = [xlist; j];
        end
    end
end
XYarray = [xlist ylist];

%% Showing ellipse and centre on original image

if strcmp(fitset,'ellipse')
    % Fit ellipse to x,y-data
    ellipse = fit_ellipse(xlist, ylist);
    figure(1)
    imshow(testmoon)
    hold on
    % ellipse centre on original image
    etX0 = ellipse.X0_in + Xup;
    etY0 = ellipse.Y0_in + Yup;
    % plot ellipse
        a = ellipse.a;
    b = ellipse.b;
    t = 0 : 0.01 : 2*pi;
    phi = -ellipse.phi;
    x = a * cos(t)*cos(phi)-b*sin(t)*sin(phi) + etX0;
    y = b * sin(t)*cos(phi)+a*cos(t)*sin(phi) + etY0;
    plot(x, y, 'LineWidth', 1,'color','red');
    % plot centre
    plot(etX0,etY0,'r*','color','blue')
    hold off
    title('Final Ellipse Estimate')
    FitData = [a, b, etX0, etY0];
    

%% Showing circle and centre on original image
elseif strcmp(fitset,'circle')
    % Fit circle to XY data
    circlefit = CircleFitByPratt(XYarray);
    figure(2)
    imshow(testmoon)
    hold on
    % Circle Centre and radius
    r = circlefit(3);
    cX0 = circlefit(1) + Xup;
    cY0 = circlefit(2) + Yup;
    % Plot Circle
    t = 0 : 0.01 : 2*pi;
    x = r*cos(t) + cX0;
    y = r*sin(t) + cY0;
    plot(x, y, 'LineWidth', 1,'color','red');
    % Plot Centre
    plot(cX0, cY0,'r*','color','blue')
    hold off
    title('Final Circle Estimate')
    close
    FitData = [r, cX0, cY0];
else
    disp('Set third parameter either to "circle" or "ellipse"')
    FitData = [NaN,NaN,NaN];
    
end
end






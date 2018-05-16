%% Navigational position determination w.r.t. celestial body in inertial space

function Distance = AutoNav(RotAngleADCS, R, XY)

%% Inputs
    % RotAngleADCS = [AngleX, AngleY, AngleZ] Rotation Angle's from
    % satellite body fixed reference frame to celestial inertial reference
    % frame in radians
    % R = Radius of celestial body in pixels
    % XY = Centroid position of celestial body position in pixels [x, y]
%% Outputs
    % NavData = [ X Y Z] Position of satellite w.r.t. celestial inertial
    % reference frame in km
    
%% Distance Determination
% Square CCD, Pixel side length
sidepixels = 1024;

% Field of View in degree
FOV = 6;

% Determination of vector position of centre of the moon in satellite body
% reference frame
Rmoon = 1737.1; %km (mean radius)
kmpixratio = Rmoon/R;
FOVkm = sidepixels*kmpixratio;

X = (XY(1)-sidepixels/2)*kmpixratio;
Y = (XY(2)-sidepixels/2)*kmpixratio;
Z = FOVkm*0.5/tan(deg2rad(FOV));

%MoonCentreVector = [X ; Y ; Z];
Distance = sqrt(X^2+Y^2+Z^2);
%CentreUnitVector = MoonCentreVector/Distance;
%%

%{

% Setting Rotation Angles
Xangle = RotAngleADCS(1) ;
Yangle = RotAngleADCS(2);
Zangle = RotAngleADCS(3);

% Defining Rotation Matrix
XRot = [1 0 0 ; 0 cos(Xangle) -sin(Xangle) ; 0 sin(Xangle) cos(Xangle)];
YRot = [cos(Yangle) 0 sin(Yangle) ; 0 1 0 ; -sin(Yangle) 0 cos(Yangle)];
ZRot = [ cos(Zangle) -sin(Zangle) 0 ; sin(Zangle) cos(Zangle) 0 ; 0 0 1];
Rot = XRot*YRot*ZRot;

% Defining Satellite Position
SatPos = Rot*MoonCentreVector*-1;

%% Output

NavData = [SatPos(1) SatPos(2) SatPos(3)];
%}






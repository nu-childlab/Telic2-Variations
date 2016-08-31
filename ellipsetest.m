% %%%%%%FUNCTION DESCRIPTION
% %This file is designed to test plotting ellipses
% %It is meant for envisioning what an image or path will look like
% %%%%%%%%%%%%%%%%%%%%%%%%%
% 
% %Math from http://stackoverflow.com/questions/29367548/how-to-apply-rotation-to-an-ellipse-defined-by-center-and-axis-lengths
% 
% %parameters
% majorAxis = 2;
% minorAxis = 1;
% centerX = 0;
% centerY = 0;
% circleAxis = .1;
% 
% orientation = -120;
% 
% %setup
% theta = linspace(0,2*pi,1000);
% orientation=orientation*pi/180;
% 
% %Plot a central circle)
% circlex = (circleAxis/2) * sin(theta) + centerX;
% circley = (circleAxis/2) * cos(theta) + centerY;
% 
% %Plot an ellipse
% x = (majorAxis/2) * sin(theta) + centerX;
% y = (minorAxis/2) * cos(theta) + centerY;
% 
% x2 = (x-centerX)*cos(orientation) - (y-centerY)*sin(orientation) + centerX;
% y2 = (x-centerX)*sin(orientation) + (y-centerY)*cos(orientation) + centerY;
% 
% %Push out a bit (the edge should hit the origin; you'll see what I mean)
% for m = 1:numel(x2)
%     xx2(m) = x2(m) + (x2(round(numel(x2)*.75)) *1);
%     yy2(m) = y2(m) + (y2(round(numel(y2)*.75)) *1);
% end
% 
% %Second ellipse
% orientation3 = 15;
% orientation3=orientation3*pi/180;
% 
% x3 = (x-centerX)*cos(orientation3) - (y-centerY)*sin(orientation3) + centerX;
% y3 = (x-centerX)*sin(orientation3) + (y-centerY)*cos(orientation3) + centerY;
% 
% %Push out a bit (the edge should hit the origin; you'll see what I mean)
% for m = 1:numel(x3)
%     xx3(m) = x3(m) + (x3(round(numel(x3)*.75)) *1);
%     yy3(m) = y3(m) + (y3(round(numel(y3)*.75)) *1);
% end
% 
% % For plotting basic ellipses
% % plot(x2,y2,circlex,circley,'--', x3,y3,'g', xx3,yy3,'m', xx2,yy2,'c')
% % axis equal
% % grid


%%%%%%%NEXT
%I'm gonna work on the for-loop point creation
numberOfLoops = 5;
numberOfFrames = 200;
xpoints = [];
ypoints = [];
majorAxis = 2;
minorAxis = 1;
centerX = 0;
centerY = 0;
theta = linspace(0,2*pi,numberOfFrames);
%The orientation starts at 0, and ends at 360-360/numberOfLoops
%This is to it doesn't make a complete circle, which would have two
%overlapping ellipses.
orientation = linspace(0,360-round(360/numberOfLoops),numberOfLoops);


for i = 1:numberOfLoops
    %orientation calculated from above
    loopOri=orientation(i)*pi/180;

    %Start with the basic, unrotated ellipse
    initx = (majorAxis/2) * sin(theta) + centerX;
    inity = (minorAxis/2) * cos(theta) + centerY;

    %Then rotate it
    x = (initx-centerX)*cos(loopOri) - (inity-centerY)*sin(loopOri) + centerX;
    y = (initx-centerX)*sin(loopOri) + (inity-centerY)*cos(loopOri) + centerY;

    %then push it out based on the rotation
    for m = 1:numel(x)
        x2(m) = x(m) + (x(round(numel(x)*.75)) *1);
        y2(m) = y(m) + (y(round(numel(y)*.75)) *1);
    end

    %It doesn't start from the right part of the ellipse, so I'm gonna
    %shuffle it around so it does. (this is important I promise)  
    %It also adds in some extra frames to smooth the transition between
    %ellipses
    start = round((numberOfFrames)/4);
    x3 = [x2(start:numberOfFrames) x2(1:start)];
    y3 = [y2(start:numberOfFrames) y2(1:start)];

    %Finally, accumulate the points in full points arrays for easy graphing
    %and drawing
    xpoints = [xpoints x3];
    ypoints = [ypoints y3];
end

% plot(xpoints, ypoints)
% axis equal
% grid


%%%%%ROTATION
minSpace = 10;


halfLoop = floor(numberOfFrames/2);
totalpoints = length(xpoints);
% %Breaks = linspace(totalpoints/numberOfLoops+1, totalpoints+1, numberOfLoops);
% numberOfBreaks = numberOfLoops - 1;
% E = totalpoints-(numberOfBreaks-2)*minSpace;
% 
% ro = rand(numberOfBreaks+1,1);
% rn = E*ro(1:numberOfBreaks)/sum(ro);
% 
% s = minSpace*ones(numberOfBreaks,1)+rn;
% 
% Breaks=cumsum(s)-1;
% 
% Breaks = reshape(Breaks, 1, length(Breaks));
% Breaks = arrayfun(@(x) round(x),Breaks);
% Breaks = [Breaks totalpoints];


start = randi(totalpoints);
new_xpoints = [xpoints(start:totalpoints) xpoints(1:start)];
new_ypoints = [ypoints(start:totalpoints) ypoints(1:start)];
Breaks = linspace(totalpoints/numberOfLoops, totalpoints+1, numberOfLoops);
Breaks = arrayfun(@(x) round(x),Breaks);

xx = new_xpoints;
yy = new_ypoints;
nx = new_xpoints;
ny = new_ypoints;

petalnum = 0;

for b=Breaks
   if start < b
       break
   else
       petalnum = petalnum + 1;
   end
end


%In this process, I wind up copying things because I might back up to a
%different point, and I don't want my calculations to mess with each other.
%(like, if I change a point, I want the calculations for future points to
%be calculated from the static previous graph, and not from any changes I
%just made.

%So, I have a couple variables that are just copies of the point sets. It's
%important, I promise.

%Move to origin
for m = 1:totalpoints-1
    if any(m==Breaks)
        petalnum = petalnum+1;
        if petalnum >= numberOfLoops
            petalnum = 0;
        end
    end
    if m == 100
        disp(nx(m))
        disp(xpoints(halfLoop + (numberOfFrames * petalnum))/2)
    end
    nx(m) = xx(m) - xpoints(halfLoop + (numberOfFrames * petalnum))/2;
    ny(m) = yy(m) - ypoints(halfLoop + (numberOfFrames * petalnum))/2;
    if m == 100
        disp(nx(m))
    end
end

%rotate
copy_nx = nx;
copy_ny = ny;
f = randi(360);

for m = 1:totalpoints-1
    if any(m == Breaks)
        f = randi(360);
    end 
    copy_nx(m) = nx(m)*cos(f) - ny(m)*sin(f);
    copy_ny(m) = ny(m)*cos(f) + nx(m)*sin(f);
end

%push out based on tip direction
final_xpoints = copy_nx;
final_ypoints = copy_ny;
petalnum = 0;

for b=Breaks
   if start < b
       break
   else
       petalnum = petalnum + 1;
   end
end

for m = 1:totalpoints-1
    if any(m == Breaks)
        petalnum = petalnum + 1;
        if petalnum >= numberOfLoops
            petalnum = 0;
        end
    end

    final_xpoints(m) = copy_nx(m) + (xpoints(halfLoop + (numberOfFrames * petalnum)) *1);
    final_ypoints(m) = copy_ny(m) + (ypoints(halfLoop + (numberOfFrames * petalnum)) *1);
end

% scale=144;
% xCenter = 1280;
% yCenter = 720;

% xpoints = (xpoints .* scale) + xCenter;
% ypoints = (ypoints .* scale) + yCenter;
% final_xpoints = (final_xpoints .* scale) + xCenter;
% final_ypoints = (final_ypoints .* scale) + yCenter;

testpoint = 100;
plot(xpoints, ypoints, final_xpoints, final_ypoints, 'r', xpoints(testpoint), ypoints(testpoint), 'bp',... 
final_xpoints(testpoint), final_ypoints(testpoint), 'rp', xpoints(testpoint)*2, ypoints(testpoint)*2, 'gp')
axis equal
grid
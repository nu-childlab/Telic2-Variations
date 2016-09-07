function [] = Telic2v3()

%%%%%%FUNCTION DESCRIPTION
%Telic2v3 is a Telic experiment where the events follow broken-up paths
%with the same shape
%It is meant for standalone use
%%%%%%%%%%%%%%%%%%%%%%%%%

Screen('Preference', 'SkipSyncTests', 0);
close all;
sca
PsychDefaultSetup(2);
screens = Screen('Screens');
screenNumber = max(screens);
rng('shuffle');
KbName('UnifyKeyNames');

cond=input('Condition e or o: ', 's');
cond = condcheck(cond);
subj=input('Subject Number: ', 's');
subj = subjcheck(subj);


%%%%%%%%
%COLOR PARAMETERS
%%%%%%%%
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
%grey = white/2;

%%%Screen Stuff

[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);
%opens a window in the most external screen and colors it)
Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
%Anti-aliasing or something? It's from a tutorial
ifi = Screen('GetFlipInterval', window);
%Drawing intervals; used to change the screen to animate the image
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
%The size of the screen window in pixels
[xCenter, yCenter] = RectCenter(windowRect);
%The center of the screen window

%%%%%%
%FINISHED PARAMETERS
%%%%%%

randomStart = true;
%Randomizes the starting point of the figure.
splitLoops = true;
%Splits the pieces apart, spaces, and rotates them
sameShapes = true;
%sameShapes only affects trials with 'equal' breaks. If false, it will add
%an additional break to those trials, thus making the number of 'pieces'
%equal to the number of loops plus 1
wroclaw = false;   
%If wroclaw is true, the experiment will have half the experiment use the
%anti-correlated times from Wroclaw

minSpace = 10;
%the minimum possible number of frames between steps

breakTime = .25;
%The number of seconds for each pause

crossTime = 1;
%Length of fixation cross time

pauseTime = .5;
%Length of space between loops presentation

textsize = 40;
textspace = 1.5;

%Matlab's strings are stupid, so I have quotes and quotes with spaces in
%variables here
quote = '''';
squote = ' ''';

%%%%%%
%LISTS
%%%%%%

correlated_values = [.75, 1.5, 2.25, 3, 3.75, 4.5, 5.25, 6, 6.75];
anticorrelated_values = [2.25, 1.5, .75, 6.75, 6, 5.25, 4.5, 3.75, 3];

pairsbase = [4; 5; 6; 7; 8; 9];
len = numel(pairsbase);
pairs = [pairsbase;pairsbase];
breaklistbase = [repmat({'equal'}, len, 1); repmat({'random'}, len, 1)];
breaklist = breaklistbase;

if wroclaw
    correlation_base = [repmat({'corr'}, len, 1); repmat({'anti'}, len, 1)];
else
    correlation_base = repmat({'corr'}, len*2, 1);
end

correlation_list = correlation_base;
reps = 4;

while reps > 0
    pairs = [pairs;pairsbase];
    breaklist = [breaklist;breaklistbase];
    correlation_list = [correlation_list;correlation_base];
    reps= reps-1;
end

shuff = randperm(length(pairs));
trial_list = pairs(shuff,:);
breaklist = breaklist(shuff);
correlation_list = correlation_list(shuff);
displayTime = 3;

if strcmp(subj, 's999')
    trial_list = [4; 4; 5; 5];
    breaklist = {'equal'; 'random';'equal'; 'random'};
    displayTime = 1;
end


%%%%%%%Screen Prep
HideCursor;	% Hide the mouse cursor
Priority(MaxPriority(window));

%%%%%%Shape Prep

theImageLocation = 'star.png';
[imagename, ~, alpha] = imread(theImageLocation);
imagename(:,:,4) = alpha(:,:);

% Get the size of the image
[s1, s2, ~] = size(imagename);

% Here we check if the image is too big to fit on the screen and abort if
% it is. See ImageRescaleDemo to see how to rescale an image.
if s1 > screenYpixels || s2 > screenYpixels
    disp('ERROR! Image is too big to fit on the screen');
    sca;
    return;
end

% Make the image into a texture
starTexture = Screen('MakeTexture', window, imagename);

scale = screenYpixels / 11;%previously 15 and 10

vbl = Screen('Flip', window);

%%%%%%DATA FILES

initprint = 0;
if ~(exist('Data/2v3/Telic2v3data.csv', 'file') == 2)
    initprint = 1;
end
dataFile = fopen('Data/2v3/Telic2v3data.csv', 'a');
subjFile = fopen(['Data/2v3/Telic2v3_' subj '.csv'],'a');
if initprint
    fprintf(dataFile, 'subject,time,condition,break,loops,response\n');
end
fprintf(subjFile, 'subject,time,condition,break,loops,response\n');
lineFormat = '%s,%6.2f,%s,%s,%d,%s\n';

%%%%%Conditions and List Setup

if strcmp(cond,'e')
    blockList = {'events', 'objects'};
else
    blockList = {'objects', 'events'};
end

%%%%%%RUNNING

instructions(window, screenXpixels, screenYpixels, textsize, textspace);

c = 1;

for condition = blockList
    if strcmp(condition,'events')
        events = 1;
    else
        events = 0;
    end
    

    %testingSentence(window, textsize, textspace, breakType, screenYpixels)

    %%%%%%RUNNING
    
    
     
    for x = 1:length(trial_list)
        %fixation cross
        fixCross(xCenter, yCenter, black, window, crossTime)
        
        %draw the thing
        numberOfLoops = trial_list(x);
        breakType = breaklist{x};
        correlationType = correlation_list{x};
        if strcmp(correlationType, 'corr')
            loopTime = correlated_values(numberOfLoops)/numberOfLoops;
        else
            loopTime = anticorrelated_values(numberOfLoops)/numberOfLoops;
        end
        framesPerLoop = round(loopTime / ifi) + 1;
        
        if events
            animateEventLoops(numberOfLoops, framesPerLoop, ...
                minSpace, scale, xCenter, yCenter, window, ...
                pauseTime, breakType, breakTime, screenNumber, starTexture, ...
                ifi, vbl, randomStart, splitLoops, sameShapes)
        else
            displayObjectLoops(numberOfLoops,...
                minSpace, scale, xCenter, yCenter, window, ...
                pauseTime, breakType, screenNumber, displayTime,...
                randomStart, splitLoops, sameShapes)
        end
        
        [response, rt] = getResponse(window, screenXpixels, screenYpixels, textsize, condition{1});
        fprintf(dataFile,lineFormat,subj,rt*1000,condition{1}, breakType,numberOfLoops,response);
        fprintf(subjFile,lineFormat,subj,rt*1000,condition{1}, breakType,numberOfLoops,response);
    end
    if c<2
        breakScreen(window, textsize, textspace);
    end
    c = c+1;

end %ending the block
%%%%%%Finishing and exiting

finish(window, textsize, textspace)
sca
Priority(0);
end













%%%%%ANIMATION FUNCTION%%%%%
function [] = animateEventLoops(numberOfLoops, framesPerLoop, ...
    minSpace, scale, xCenter, yCenter, window, ...
    pauseTime, breakType, breakTime, screenNumber, imageTexture, ...
    ifi, vbl, randomStart, splitLoops, sameShapes)
    white = WhiteIndex(screenNumber);
    black = BlackIndex(screenNumber);
    grey = white/2;
    [xpoints, ypoints] = getPoints(numberOfLoops, framesPerLoop);
    totalpoints = numel(xpoints);
    if randomStart
        [xpoints, ypoints, start] = randomizeStartPoint(xpoints, ypoints);
    else
        start = 1;
    end
    [Breaks] = makeBreaks(breakType, sameShapes, totalpoints, numberOfLoops, minSpace);
    if splitLoops
        [xpoints, ypoints] = rotatePoints(xpoints, ypoints, framesPerLoop, Breaks, start);
    end
    xpoints = (xpoints .* scale) + xCenter;
    ypoints = (ypoints .* scale) + yCenter;
    [xpoints, ypoints, Breaks] = scrambleOrder(xpoints, ypoints, Breaks);
    
    pt = 1;
    waitframes = 1;
    Screen('FillRect', window, grey);
    Screen('Flip', window);
    while pt <= totalpoints
        if ~any(pt == Breaks)%&& ~any(pt+1 == Breaks)
            destRect = [xpoints(pt) - 128/2, ... %left
                ypoints(pt) - 128/2, ... %top
                xpoints(pt) + 128/2, ... %right
                ypoints(pt) + 128/2]; %bottom

            % Draw the shape to the screen
            Screen('DrawTexture', window, imageTexture, [], destRect, 0);
            Screen('DrawingFinished', window);
            % Flip to the screen
            vbl  = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
            
        end
        pt = pt + 1;
        %If the current point is a break point, pause
        if any(pt == Breaks)
            WaitSecs(breakTime);
        end
        
    end
    Screen('FillRect', window, black);
    vbl = Screen('Flip', window);
    WaitSecs(pauseTime);
end


function [] = displayObjectLoops(numberOfLoops,...
    minSpace, scale, xCenter, yCenter, window, ...
    pauseTime, breakType, screenNumber, displayTime,...
    randomStart, splitLoops, sameShapes)

    %I have a set number of frames for the display objects, because adding
    %more frames makes the drawings smoother and, unlike in events, has no
    %effect on the time.
    dispframes = 200;
    white = WhiteIndex(screenNumber);
    black = BlackIndex(screenNumber);
    grey = white/2;
    [xpoints, ypoints] = getPoints(numberOfLoops, dispframes);
    totalpoints = numel(xpoints);
    if randomStart
        [xpoints, ypoints, start] = randomizeStartPoint(xpoints, ypoints);
    else
        start = 1;
    end
    [Breaks] = makeBreaks(breakType, sameShapes, totalpoints, numberOfLoops, minSpace);
    if splitLoops
        [xpoints, ypoints] = rotatePoints(xpoints, ypoints, dispframes, Breaks, start);
    end
    xpoints = (xpoints .* scale) + xCenter;
    ypoints = (ypoints .* scale) + yCenter;
    Screen('FillRect', window, grey);
    Screen('Flip', window);
    for p = 1:totalpoints - 2
        if ~any(p == Breaks) && ~any(p+1 == Breaks)
            Screen('DrawLine', window, black, xpoints(p), ypoints(p), ...
                xpoints(p+1), ypoints(p+1), 5);
        end
    end
    Screen('Flip', window);
    WaitSecs(displayTime);
    Screen('FillRect', window, black);
    Screen('Flip', window);
    WaitSecs(pauseTime);
end

%%%%%%SENTENCE FUNCTIONS%%%%%%%%%
function [] = instructions(window, screenXpixels, screenYpixels, textsize, textspace)
    Screen('TextFont',window,'Arial');
    Screen('TextSize',window,textsize);
    white = WhiteIndex(window);
    textcolor = white;
    quote = '''';
    
    intro = ['In this experiment, you will be asked to consider some images'...
        ' and animations. Your task is to decide how you would prefer to describe'...
        ' what is displayed in each image or animation. \n \n'...
        'You will be able to indicate your preference using the '...
        quote 'f' quote ' and ' quote, 'j'  quote ' keys.'];

    DrawFormattedText(window, intro, 'center', screenYpixels/2 - screenYpixels/3, textcolor, 70, 0, 0, textspace);
    Screen('TextSize',window,textsize + 4);
    DrawFormattedText(window, ['Press ' quote 'f' quote ' if you prefer \n'...
        'the sentence on the left.'],screenXpixels/2 - screenXpixels/3, 'center', textcolor, 70);
    DrawFormattedText(window, ['Press ' quote 'j' quote ' if you prefer \n'...
        'the sentence on the right.'],screenXpixels/2 + screenXpixels/6, 'center', textcolor, 70);
    Screen('TextSize',window,textsize);
    intro2 = ['Please indicate to the experimenter if you have any questions, '...
        'or are ready to begin the experiment. \n When the experimenter has '...
        'left the room, you may press spacebar to begin.'];
    
    DrawFormattedText(window, intro2, 'center', 2*screenYpixels/3, textcolor, 70, 0, 0, textspace);
    Screen('Flip', window);
    RestrictKeysForKbCheck(KbName('space'));
    KbStrokeWait;
    Screen('Flip', window);
    RestrictKeysForKbCheck([]);
end

function [] = breakScreen(window, textsize, textspace)
    Screen('TextFont',window,'Arial');
    Screen('TextSize',window,textsize);
    black = BlackIndex(window);
    white = WhiteIndex(window);
    textcolor = white;
    quote = '''';
    DrawFormattedText(window, ['That' quote 's it for that block! \n\n' ...
        ' Please press the spacebar when you are ready to continue to the next block. '], 'center', 'center',...
        textcolor, 70, 0, 0, textspace);
    Screen('Flip', window);
    % Wait for keypress
    RestrictKeysForKbCheck(KbName('space'));
    KbStrokeWait;
    Screen('Flip', window);
    RestrictKeysForKbCheck([]);
end

function [] = finish(window, textsize, textspace)
    Screen('TextFont',window,'Arial');
    Screen('TextSize',window,textsize);
    black = BlackIndex(window);
    white = WhiteIndex(window);
    textcolor = white;
    closing = ['Thank you for your participation.\n\nPlease let the ' ...
        'experimenter know that you are finished.'];
    DrawFormattedText(window, closing, 'center', 'center', textcolor, 70, 0, 0, textspace);
    Screen('Flip', window);
    % Wait for keypress
    RestrictKeysForKbCheck(KbName('ESCAPE'));
    KbStrokeWait;
    Screen('Flip', window);
    RestrictKeysForKbCheck([]);
end


%%%%%%RESPONSE FUNCTION%%%%%


function [response, time] = getResponse(window, screenXpixels, screenYpixels, textsize, cond)
    white = WhiteIndex(window);
    textcolor = white;
    Screen('TextFont',window,'Arial');
    Screen('TextSize',window,textsize);
    quote = '''';
    if strcmp(cond, 'objects')
        question = 'How would you prefer to describe that image?';
        optf = 'There were some GORPS.';
        optj = 'There was some GORP.';
    else
        question = 'How would you prefer to describe that animation?';
        optf = 'The star did some GLEEBS.';
        optj = 'The star did some GLEEBING.';
    end

    DrawFormattedText(window, question, 'center', screenYpixels/3, textcolor, 70);
    
    Screen('TextSize',window,textsize + 4);
    DrawFormattedText(window, optf, screenXpixels/2 - screenXpixels/3, 'center', textcolor, 70);
    DrawFormattedText(window, optj, screenXpixels/2 + screenXpixels/9, 'center', textcolor, 70);
    
    Screen('TextSize',window,textsize);
    DrawFormattedText(window, ['Press ' quote 'f' quote],...
        screenXpixels/2 - screenXpixels/3 + 200, screenYpixels/2+30, textcolor, 70);
    DrawFormattedText(window, ['Press ' quote 'j' quote],...
        screenXpixels/2 + screenXpixels/9 + 200, screenYpixels/2+30, textcolor, 70);
        
    Screen('Flip',window);

    % Wait for the user to input something meaningful
    RestrictKeysForKbCheck([KbName('f') KbName('j')]);
    inLoop=true;
    yesno = [KbName('f') KbName('j')];
    starttime = GetSecs;
    while inLoop
        %code = [];
        [keyIsDown, ~, keyCode]=KbCheck;
        if keyIsDown
            code = find(keyCode);
            if any(code(1) == yesno)
                endtime = GetSecs;
                if code == KbName('f')
                    response = 'f';
                end
                if code== KbName('j')
                    response= 'j';
                end
                inLoop=false;
            end
        end
    end
    time = endtime - starttime;
    RestrictKeysForKbCheck([]);
end




%%%%%%FIXATION CROSS FUNCTION%%%%%

function[] = fixCross(xCenter, yCenter, black, window, crossTime)
    white = WhiteIndex(window);
    Screen('FillRect', window, white/2);
    fixCrossDimPix = 40;
    xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
    yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
    allCoords = [xCoords; yCoords];
    lineWidthPix = 4;
    Screen('DrawLines', window, allCoords,...
        lineWidthPix, black, [xCenter yCenter], 2);
    Screen('Flip', window);
    WaitSecs(crossTime);
end


%%%%%POINTS AND BREAKS FUNCTIONS%%%%%


function [xpoints, ypoints] = getPoints(numberOfLoops, numberOfFrames)

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
        x3 = [x2(start:numberOfFrames) x2(2:start)];
        y3 = [y2(start:numberOfFrames) y2(2:start)];
        %Finally, accumulate the points in full points arrays for easy graphing
        %and drawing
        xpoints = [xpoints x3];
        ypoints = [ypoints y3];
    end
end

function [new_xpoints, new_ypoints, start] = randomizeStartPoint(xpoints, ypoints)
    start = randi(numel(xpoints));
    new_xpoints = [xpoints(start:numel(xpoints)) xpoints(1:start)];
    new_ypoints = [ypoints(start:numel(xpoints)) ypoints(1:start)];
end

function [Breaks] = makeBreaks(breakType, sameShapes, totalpoints, loops, minSpace)
    if strcmp(breakType, 'equal')
        if sameShapes
            %This is the basic equal breaks calculation
            Breaks = linspace(totalpoints/loops, totalpoints+1, loops);
        else
            %To prevent the lines from forming the same shapes, an extra
            %break is added in
            Breaks = linspace(totalpoints/loops, totalpoints+1, loops+1);
        end
        Breaks = arrayfun(@(x) round(x),Breaks);

    elseif strcmp(breakType, 'random')
        %tbh I found this on stackoverflow and have no idea how it works
        %http://stackoverflow.com/questions/31971344/generating-random-sequence-with-minimum-distance-between-elements-matlab/31977095#31977095
        if loops >1
            numberOfBreaks = loops - 1;
            %The -minSpace accounts for some distance away from the last point,
            %which I add on separately.
            E = (totalpoints-minSpace)-(numberOfBreaks-1)*minSpace;

            ro = rand(numberOfBreaks+1,1);
            rn = E*ro(1:numberOfBreaks)/sum(ro);

            s = minSpace*ones(numberOfBreaks,1)+rn;

            Breaks=cumsum(s)-1;

            Breaks = reshape(Breaks, 1, length(Breaks));
            Breaks = arrayfun(@(x) round(x),Breaks);
            Breaks = sort([Breaks totalpoints+1]);
            
            
        else
            Breaks = totalpoints+1;
        end
        %I'm adding one break on at the end, otherwise I'll end up with
        %more "pieces" than in the equal condition.

    else
        Breaks = [];
    end
end

function [final_xpoints, final_ypoints] = rotatePoints(xpoints, ypoints, numberOfFrames, Breaks, start)
    %This is set up because the randomized start point and/or the
    %additional break can mess with the directionality.
    [init_xpoints, init_ypoints] = getPoints(numel(Breaks), numberOfFrames);
    nx = xpoints;
    ny = ypoints;
    halfLoop = floor(numberOfFrames/2);
    totalpoints = length(xpoints);
    numberOfLoops = numel(Breaks);

    petalnum = 0;
    %Usually, the start is 1, so the petalnum starts at 0. However, a
    %randomized start point may require a different initial direction of
    %rotation
    for b=Breaks
       if start <= b
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
        nx(m) = xpoints(m) - init_xpoints(halfLoop + (numberOfFrames * petalnum))/2;
        ny(m) = ypoints(m) - init_ypoints(halfLoop + (numberOfFrames * petalnum))/2;
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
        final_xpoints(m) = copy_nx(m) + (init_xpoints(halfLoop + (numberOfFrames * petalnum)) *1.3);
        final_ypoints(m) = copy_ny(m) + (init_ypoints(halfLoop + (numberOfFrames * petalnum)) *1.3);
    end

end

function [new_xpoints, new_ypoints, new_breaks] = scrambleOrder(xpoints, ypoints, Breaks)
    x_sections = {};
    x_temp = [];
    y_sections = {};
    y_temp = [];
    section_count = 1;
    for i = 1:length(xpoints)
        x_temp = [x_temp xpoints(i)];
        y_temp = [y_temp ypoints(i)];
        if any(i == Breaks)
            x_sections{section_count} = x_temp;
            y_sections{section_count} = y_temp;
            section_count = section_count + 1;
            x_temp = [];
            y_temp = [];
        end
    end
    x_sections{section_count} = x_temp;
    y_sections{section_count} = y_temp;
    shuff = randperm(length(x_sections));
    x_sections = x_sections(shuff);
    y_sections = y_sections(shuff);
    new_xpoints = [];
    new_ypoints = [];
    new_breaks = [];
    break_tally = 0;
    for sect = 1:length(x_sections)
        break_tally = break_tally + length(x_sections{sect});
        new_breaks = [new_breaks break_tally];
        new_xpoints = [new_xpoints x_sections{sect}];
        new_ypoints = [new_ypoints y_sections{sect}];
    end
end


%%%%%%%%%
%INPUT CHECKING FUNCTIONS
%%%%%%%%%

function [subj] = subjcheck(subj)
    if ~strncmpi(subj, 's', 1)
        %forgotten s
        subj = ['s', subj];
    end
    if strcmp(subj,'s')
        subj = input(['Please enter a subject ' ...
                'ID:'], 's');
        subj = subjcheck(subj);
    end
    numstrs = ['1'; '2'; '3'; '4'; '5'; '6'; '7'; '8'; '9'; '0'];
    for x = 2:numel(subj)
        if ~any(subj(x) == numstrs)
            subj = input(['Subject ID ' subj ' is invalid. It should ' ...
                'consist of an "s" followed by only numbers. Please use a ' ...
                'different ID: '], 's');
            subj = subjcheck(subj);
            return
        end
    end
    if (exist(['~/Desktop/Data/TELIC/TELICWROCLAW/TelicWroclaw' subj '.csv'], 'file') == 2) && ~strcmp(subj, 's999')...
            && ~strcmp(subj,'s998')
        temp = input(['Subject ID ' subj ' is already in use. Press y '...
            'to continue writing to this file, or press '...
            'anything else to try a new ID: '], 's');
        if strcmp(temp,'y')
            return
        else
            subj = input(['Please enter a new subject ' ...
                'ID:'], 's');
            subj = subjcheck(subj);
        end
    end
end

function [cond] = condcheck(cond)
    while ~strcmp(cond, 'e') && ~strcmp(cond, 'o')
        cond = input('Condition must be e or o. Please enter e (events) or o (objects): ', 's');
    end
end

function [list] = listcheck(list)
    if strcmp(list, 'test')
        check = input('Type y to continue using a test list. Type anything else to abort the program: ', 's');
        if strcmp(check, 'y')
            return
        else
            error('Process aborted')
        end
    end
    while ~strcmp(list, 'blue') && ~strcmp(list, 'pink') && ~strcmp(list, 'green') && ~strcmp(list, 'orange') && ~strcmp(list, 'yellow')
        list = input('List must be a valid color. Please enter blue, pink, green, orange, or yellow: ', 's');
    end
end
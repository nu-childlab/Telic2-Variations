function [] = TelicWroclaw()

%%%%%%FUNCTION DESCRIPTION
%TelicWroclaw is a Telic experiment that manipulates time correlation
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

cond=input('Condition m or c: ', 's');
cond = condcheck(cond);
subj=input('Subject Number: ', 's');
subj = subjcheck(subj);
list=input('List color: ', 's');
list = listcheck(list);

%%%%%%%%
%COLOR PARAMETERS
%%%%%%%%
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white/2;

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



minSpace = 10;
%the minimum possible number of frames between steps

breakTime = .5;
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

correlation_list = {'corr';'corr';'corr';'corr';'corr';'corr';'corr';...
    'corr';'corr';'corr';'anti';'anti';'anti';'anti';'anti';'anti';...
    'anti';'anti';'anti';'anti'};

if strcmp(list, 'test')
    trial_list = {[4 5; 5 4;]; [9 7; 7 9]};
    trial_list = [trial_list;trial_list];
    correlation_list = {'corr';'corr';'anti';'anti'};
elseif strcmp(list, 'blue')
    trial_list = {[4 5; 5 4;]; [4 6; 6 4]; [4 7; 7 4]; [4 8; 8 4]; [4 9; 9 4]; ...
        [9 4; 4 9]; [9 5; 5 9]; [9 6; 6 9]; [9 7; 7 9]; [9 8; 8 9]};
    trial_list = [trial_list;trial_list];
elseif strcmp(list, 'pink')
    trial_list = {[5 6; 6 5]; [5 7; 7 5]; [5 8; 8 5]; [5 9; 9 5]; [4 9; 9 4]; ...
        [9 4; 4 9]; [8 4; 4 8]; [8 5; 5 8]; [8 6; 6 8]; [8 7; 7 8]};
    trial_list = [trial_list;trial_list];
elseif strcmp(list, 'green')
    trial_list = {[6 7; 7 6]; [6 8; 8 6]; [6 9; 9 6]; [5 9; 9 5]; [4 9; 9 4]; ...
        [9 4; 4 9]; [8 4; 4 8]; [7 4; 4 7]; [7 5; 5 7]; [7 6; 6 7]};
    trial_list = [trial_list;trial_list];
elseif strcmp(list, 'orange')
    trial_list = {[7 8; 8 7]; [6 8; 8 6]; [5 8; 8 5]; [4 8; 8 4]; [4 9; 9 4]; ...
        [9 4; 4 9]; [9 5; 5 9]; [8 5; 5 8]; [7 5; 5 7]; [6 5; 5 6]};
    trial_list = [trial_list;trial_list];
elseif strcmp(list, 'yellow')
    trial_list = {[4 9; 9 4]; [5 9; 9 5]; [6 9; 9 6]; [7 9; 9 7]; [8 9; 9 8]; ...
        [5 4; 4 5]; [6 4; 4 6]; [7 4; 4 7]; [8 4; 4 8]; [9 4; 4 9]};
    trial_list = [trial_list;trial_list];
end

shuff = randperm(length(trial_list));
trial_list = trial_list(shuff,:);
correlation_list = correlation_list(shuff);


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

theImageLocation = 'heart.png';
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
heartTexture = Screen('MakeTexture', window, imagename);

scale = screenYpixels / 10;%previously 15

vbl = Screen('Flip', window);

%%%%%%DATA FILES

initprint = 0;
if ~(exist('Data/Wroclaw/TelicWroclawdata.csv', 'file') == 2)
    initprint = 1;
end
dataFile = fopen('Data/Wroclaw/TelicWroclawdata.csv', 'a');
subjFile = fopen(['Data/Wroclaw/TelicWroclaw' subj '.csv'],'a');
if initprint
    fprintf(dataFile, ['subj,time,cond,break,list,star loops,heart loops,contrast,correlated?,total star time,total heart time,response\n']);
end
fprintf(subjFile, 'subj,time,cond,break,list,star loops,heart loops,contrast,correlated?,total star time,total heart time,response\n');
lineFormat = '%s,%6.2f,%s,%s,%s,%d,%d,%d,%s,%6.2f,%6.2f,%s\n';

%%%%%Conditions and List Setup

if strcmp(cond,'m')
    blockList = {'mass', 'count'};
else
    blockList = {'count', 'mass'};
end

correlated_values = [.75, 1.5, 2.25, 3, 3.75, 4.5, 5.25, 6, 6.75];
%anticorrelated_values = [9, 8.25, 7.5, 6.75, 6, 5.25, 4.5, 3.75, 3];
anticorrelated_values = [2.25, 1.5, .75, 6.75, 6, 5.25, 4.5, 3.75, 3];

%%%%%%RUNNING

instructions(window, screenXpixels, screenYpixels, textsize, textspace)
c = 1;
training_list = [1;2;3;1;2;3];
training_correlation = {'corr'; 'corr'; 'corr'; 'anti'; 'anti'; 'anti'};
training_shape = {'star'; 'star'; 'star'; 'heart'; 'heart'; 'heart'};

for condition = blockList
    if strcmp(condition,'mass')
        breakType = 'random';
        cond = 'mass';
    else
        breakType='equal';
        cond = 'count';
    end
    
    shuff = randperm(length(training_list));
    training_list = training_list(shuff,:);
    training_correlation = training_correlation(shuff,:);
    training_shape = training_shape(randperm(length(training_shape)),:);

    %%%%%%TRAINING
    
    for t = 1:length(training_list)
        numberOfLoops = training_list(t);
        if strcmp(training_correlation{t}, 'corr')
            totaltime = correlated_values(numberOfLoops);
        else
            totaltime = anticorrelated_values(numberOfLoops);
        end
        if strcmp(training_shape{t}, 'star')
            training_image = starTexture;
        else
            training_image = heartTexture;
        end
        
        if t == 1
            phase = 1;
        elseif t == length(training_list)
            phase = 3;
        else
            phase = 2;
        end
               
        loopTime = totaltime/numberOfLoops;
        framesPerLoop = round(loopTime / ifi) + 1;
        trainSentence(window, textsize, textspace, phase, training_shape{t}, breakType, screenYpixels);
        animateEventLoops(numberOfLoops, framesPerLoop, ...
            minSpace, scale, xCenter, yCenter, window, ...
            pauseTime, breakType, breakTime, screenNumber, training_image, ...
            ifi, vbl)
    end

    testingSentence(window, textsize, textspace, breakType, screenYpixels)

    %%%%%%RUNNING
    
    
     
    for x = 1:length(trial_list)
        
        %fixation cross
        fixCross(xCenter, yCenter, black, window, crossTime)
        
        %first animation, with star
        trial = trial_list{x};
        trial = trial(randi([1,2]),:);
        numberOfLoops = trial(1);
        startotaltime = anticorrelated_values(numberOfLoops);
        if strcmp(correlation_list{x}, 'corr')
            startotaltime = correlated_values(numberOfLoops);
        end
        loopTime = startotaltime/numberOfLoops;
        framesPerLoop = round(loopTime / ifi) + 1;

        animateEventLoops(numberOfLoops, framesPerLoop, ...
            minSpace, scale, xCenter, yCenter, window, ...
            pauseTime, breakType, breakTime, screenNumber, starTexture, ...
            ifi, vbl)
        
        %fixation cross
        fixCross(xCenter, yCenter, black, window, crossTime)
        
        %second animation, with heart
        numberOfLoops = trial(2);
        hearttotaltime = anticorrelated_values(numberOfLoops);
        if strcmp(correlation_list{x}, 'corr')
            hearttotaltime = correlated_values(numberOfLoops);
        end
        loopTime = hearttotaltime/numberOfLoops;
        framesPerLoop = round(loopTime / ifi) + 1;

        animateEventLoops(numberOfLoops, framesPerLoop, ...
            minSpace, scale, xCenter, yCenter, window, ...
            pauseTime, breakType, breakTime, screenNumber, heartTexture, ...
            ifi, vbl)
        
        [response, time] = getResponse(window, breakType, textsize, screenYpixels);
%         response = 'na';
%         time = 0;
        fprintf(dataFile, lineFormat, subj, time*1000, cond, breakType, list, trial(1),...
            trial(2), abs(trial(1) - trial(2)),correlation_list{x},startotaltime,hearttotaltime,response);
        fprintf(subjFile, lineFormat, subj, time*1000, cond, breakType, list, trial(1),...
            trial(2), abs(trial(1) - trial(2)),correlation_list{x},startotaltime,hearttotaltime,response);
    end
    if c
        breakScreen(window, textsize, textspace);
    end
    c = c-1;

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
    ifi, vbl)
    white = WhiteIndex(screenNumber);
    black = BlackIndex(screenNumber);
    grey = white/2;
    [xpoints, ypoints] = getPoints(numberOfLoops, framesPerLoop);
    totalpoints = numel(xpoints);
    Breaks = makeBreaks(breakType, totalpoints, numberOfLoops, minSpace);
    xpoints = (xpoints .* scale) + xCenter;
    ypoints = (ypoints .* scale) + yCenter;
    %points = [xpoints ypoints];
    pt = 1;
    waitframes = 1;
    Screen('FillRect', window, grey);
    Screen('Flip', window);
    while pt <= totalpoints
        %If the current point is a break point, pause
        if any(pt == Breaks)
            WaitSecs(breakTime);
        end
        destRect = [xpoints(pt) - 128/2, ... %left
            ypoints(pt) - 128/2, ... %top
            xpoints(pt) + 128/2, ... %right
            ypoints(pt) + 128/2]; %bottom
        
        % Draw the shape to the screen
        Screen('DrawTexture', window, imageTexture, [], destRect, 0);
        Screen('DrawingFinished', window);
        % Flip to the screen
        vbl  = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
        pt = pt + 1;
        
    end
    Screen('FillRect', window, black);
    vbl = Screen('Flip', window);
    WaitSecs(pauseTime);
end

%%%%%%INSTRUCTIONS, BREAK, AND FINISH FUNCTION%%%%%%%%%
function [] = instructions(window, screenXpixels, screenYpixels, textsize, textspace)
    Screen('TextFont',window,'Arial');
    Screen('TextSize',window,textsize);
    black = BlackIndex(window);
    white = WhiteIndex(window);
    textcolor = white;
    xedgeDist = floor(screenXpixels / 3);
    quote = '''';
    intro = ['Welcome to the experiment. In this experiment, you will be asked to answer',...
        ' questions relative to short animations. There are 2 blocks in the experiment,',...
        ' and each block contains 20 trials. In each block, you will be asked to evaluate',...
        ' a different question. You will be given a short break between blocks. \n\n',...
        ' For each animation, you will indicate whether the sentence accurately describes',...
        ' that animation by pressing ' quote 'f' quote ' for YES or ' quote 'j' quote ' for NO.',...
        ' You will be reminded of these response keys throughout. '];
    
    DrawFormattedText(window, intro, 'center', screenYpixels/7, textcolor, 70, 0, 0, textspace);
    
    intro2 = ['The experiment will proceed in two main parts. Please indicate to the experimenter if you have any questions, '...
        'or are ready to begin the experiment. \n\n When the experimenter has '...
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
end


%%%%%%RESPONSE FUNCTION%%%%%

function [response, time] = getResponse(window, breakType, textsize, screenYpixels)
    black = BlackIndex(window);
    white = WhiteIndex(window);
    textcolor = white;
    Screen('TextFont',window,'Arial');
    Screen('TextSize',window,textsize+6);
    quote = '''';
    if strcmp(breakType, 'random')
        verb = 'gleeb';
    else
        verb = 'blick';
    end
    DrawFormattedText(window, ['Did the star ' verb ' more than the heart?'],...
        'center', 'center', textcolor, 70, 0, 0, 1.5);
    Screen('TextSize',window,textsize);
    DrawFormattedText(window, ['Press ' quote 'f' quote ' for YES and ' quote 'j' quote ' for NO'],...
        'center', screenYpixels/2 + 80, textcolor, 70);
    Screen('Flip',window);

    % Wait for the user to input something meaningful
    inLoop=true;
    %response = '-1';
    yesno = [KbName('f') KbName('j')];
    starttime = GetSecs;
    while inLoop
        %code = [];
        [keyIsDown, ~, keyCode]=KbCheck;
        if keyIsDown
            code = find(keyCode);
            if any(code(1) == yesno)
                endtime = GetSecs;
                if code == 9
                    response = 'f';
                    inLoop=false;
                end
                if code== 13
                    response= 'j';
                    inLoop=false;
                end
            end
        end
    end
    time = endtime - starttime;
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


%%%%%SENTENCE/INSTRUCTIONS FUNCTIONS%%%%%

function [] = trainSentence(window, textsize, textspace, phase, shape, breakType, screenYpixels)
    Screen('TextFont',window,'Arial');
    Screen('TextSize',window,textsize + 5);
    black = BlackIndex(window);
    white = WhiteIndex(window);
    Screen('FillRect', window, black);
    Screen('Flip', window);
    quote = '''';
    if strcmp(breakType, 'random')
        verb = 'gleeb';
    else
        verb = 'blick';
    end
    
    switch phase
        case 1
            DrawFormattedText(window, ['You' quote 're going to see the ' shape ' ' verb 'ing.'],...
                'center', 'center', white, 70, 0, 0, textspace);
        case 2
            DrawFormattedText(window, ['Now you' quote 're going to see the '...
                shape ' doing some more ' verb 'ing.'],...
                'center', 'center', white, 70, 0, 0, textspace);
        case 3
            if strcmp(breakType, 'random')
                DrawFormattedText(window, ['Last one for now. You' quote ...
                    're going to see the ' shape ' ' verb 'ing.'],...
                    'center', 'center', white, 70, 0, 0, textspace);
            else
                DrawFormattedText(window, ['Let' quote 's see that again. You' ...
                    quote 're going to see the ' shape ' ' verb 'ing some more.'],...
                    'center', 'center', white, 70, 0, 0, textspace);
            end
    end
    
    Screen('TextSize',window,textsize);
    DrawFormattedText(window, 'Ready? Press spacebar.', 'center', ...
        screenYpixels/2+50, white, 70, 0, 0, textspace);
    Screen('Flip', window);
    % Wait for keypress
    RestrictKeysForKbCheck(KbName('space'));
    KbStrokeWait;
    Screen('Flip', window);
    RestrictKeysForKbCheck([]);
end

function [] = testingSentence(window, textsize, textspace, breakType, screenYpixels)
    Screen('TextFont',window,'Arial');
    Screen('TextSize',window,textsize);
    black = BlackIndex(window);
    white = WhiteIndex(window);
    Screen('FillRect', window, black);
    Screen('Flip', window);
    quote = '''';
    if strcmp(breakType, 'random')
        verb = 'gleeb';
    else
        verb = 'blick';
    end
    
    DrawFormattedText(window, ['Now you' quote 're going to see pairs of '...
        'videos, involving the star and a heart. For each pair, you are '...
        'going to be asked:'], 'center', screenYpixels/2-(screenYpixels/5), white, 70, 0, 0, textspace);
    
    Screen('TextSize',window,textsize+15);
    DrawFormattedText(window, ['Did the star ' verb ' more than the heart?'],...
                'center', 'center', white, 70, 0, 0, textspace);
    Screen('TextSize',window,textsize);
    DrawFormattedText(window, 'Ready? Press spacebar.', 'center', ...
        screenYpixels/2+(screenYpixels/5), white, 70, 0, 0, textspace);
    Screen('Flip', window);
    % Wait for keypress
    RestrictKeysForKbCheck(KbName('space'));
    KbStrokeWait;
    Screen('Flip', window);
    RestrictKeysForKbCheck([]);
end

%%%%%POINTS AND BREAKS FUNCTIONS%%%%%


function [xpoints, ypoints] = getPoints(numberOfLoops, numberOfFrames)
    %OK, so, the ellipses weren't lining up at the origin very well, so
    %smoothframes designates a few frames to smooth this out. It uses fewer
    %frames for the ellipse, and instead spends a few frames going from the
    %end of the ellipse to the origin.
    smoothframes = 0;
    doublesmooth = smoothframes*2;
    xpoints = [];
    ypoints = [];
    majorAxis = 2;
    minorAxis = 1;
    centerX = 0;
    centerY = 0;
    theta = linspace(0,2*pi,numberOfFrames-smoothframes);
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
        start = round((numberOfFrames-smoothframes)/4);
        x3 = [x2(start:numberOfFrames-smoothframes) x2(2:start) linspace(x2(start),0,smoothframes)];
        y3 = [y2(start:numberOfFrames-smoothframes) y2(2:start) linspace(y2(start),0,smoothframes)];
        %Finally, accumulate the points in full points arrays for easy graphing
        %and drawing
        xpoints = [xpoints x3];
        ypoints = [ypoints y3];
    end
end

function [Breaks] = makeBreaks(breakType, totalpoints, loops, minSpace)
    if strcmp(breakType, 'equal')
        Breaks = 1 : totalpoints/loops : totalpoints;

    elseif strcmp(breakType, 'random')
        %tbh I found this on stackpverflow and have no idea how it works
        %lol
        E = totalpoints-(loops-1)*minSpace;

        ro = rand(loops+1,1);
        rn = E*ro(1:loops)/sum(ro);

        s = minSpace*ones(loops,1)+rn;

        Breaks=cumsum(s)-1;
        
        Breaks = reshape(Breaks, 1, length(Breaks));
        Breaks = arrayfun(@(x) round(x),Breaks);

    else
        Breaks = [];
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
    while ~strcmp(cond, 'm') && ~strcmp(cond, 'c')
        cond = input('Condition must be m or c. Please enter m (mass) or q (count): ', 's');
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
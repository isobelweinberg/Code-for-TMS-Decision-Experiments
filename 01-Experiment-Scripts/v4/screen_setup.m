function [screen] = screen_setup(params)

Priority(1);

%Use line below to make window transparent for debugging
%     PsychDebugWindowConfiguration();

Screen('Preference', 'SkipSyncTests', 0);

%Open a window
screen.windowNo = Screen('OpenWindow', 0, params.BackgroundColour);%0 is the main
Screen('BlendFunction', screen.windowNo, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA' ); %anti-aliasing
screen.RefreshRate = Screen('FrameRate', screen.windowNo); %in Hz; PTB asks the screen what its refresh rate is

%Find the centre of the screen
middlerect = Screen('Rect', screen.windowNo);
screen.xmiddle=middlerect(1,3)*0.5;
screen.ymiddle=middlerect(1,4)*0.5;

end

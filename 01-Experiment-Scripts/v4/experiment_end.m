function experiment_end(screen);
DrawFormattedText(screen.windowNo, 'Experiment finished! Press any key to continue.', 'center', 'center', [0 0 0]);
Screen('Flip', screen.windowNo);
KbStrokeWait;
sca;
Priority(0);
end
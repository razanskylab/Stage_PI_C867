% P = PiStage();

% P.Define_Position_Trigger(...
% 	'res', 0.1, ...
% 	'startPos', 10, ...
% 	'stopPos', 20, ...
% 	'polarity', 'pos', ...
% 	'outputChannel', 1);

P.Define_Position_Trigger();
P.Enable_Trigger('outputChannel', 1);
for iScan = 1:10
	P.pos = 9.9;
	P.pos = 20.1;
end
P.Enable_Trigger('outputChannel', 1, 'state', 0);


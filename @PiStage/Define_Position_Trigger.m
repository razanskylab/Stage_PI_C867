% File: Define_Position_Trigger.m @ PiStage
% Author: Urs Hofmann
% Mail: hofmannu@ethz.ch
% Date: 14.07.2021

% Description: Defines a position dependent trigger at the output of the PiStage

function Define_Position_Trigger(ps, varargin)

	% default input arguments
	res = 0.02; % trigger step resolution [mm]
	startPos = 0; % start position for trigger event [mm]
	stopPos = 0; % stop position for trigger event [mm]
	outputChannel = 1; % which output channel are we working on
	polarity = 'pos'; % polarity of trigger signal [pos, neg]
	pulseWidth = 0.5; % pulse width in micros
	triggerMode = 7;

	% read in user defined input arguments
	for (iargin = 1:2:(nargin -1))
		switch varargin{iargin}
			case 'res'
				res = varargin{iargin + 1};
			case 'startPos'
				startPos = varargin{iargin + 1};
			case 'stopPos'
				stopPos = varargin{iargin + 1};
			case 'outputChannel'
				outputChannel = varargin{iargin + 1};
			case 'polarity'
				polarity = varargin{iargin + 1};
			case 'pulseWidth'
				pulseWidth = varargin{iargin + 1};
		otherwise
			error("Invalid argument passed to function");
		end
	end

	% The first trigger pulse is to be output on digital output line 1 if the 
	% absolute position of axis 1 is 1.5 mm. A pulse should then be output on this 
	% line every time axis 1 has covered a distance of 0.5 μm in the positive 
	% direction. The last trigger pulse is to be output if the absolute axis 
	% position is 2.5 mm. The pulse width should be approximately 0.8 μs.
	% TRO 1 1

	% CTO 1 1 0.001					resolution
	% CTO 1 2 1 						axis
	% CTO 1 3 0 						trigger mode --> see end of file
	% CTO 1 7 1 						polarity, 0: active low, 1: active high
	% CTO 1 8 -214748.3647	startPos
	% CTO 1 9 214748.3647 	stopPos
	% CTO 1 10 30 					triggerPosition
	% CTO <TrigOutID> 11 n 	pulseWitdth in n * 33 ns

	% BOOL PI_CTO (
	% 		int ID, 
	% 		const int* piTriggerOutputIds,
	% 		const int* piTriggerParameterArray,
	% 		const double* pdValueArray, 
	% 		int iArraySize)
	% 
	% Corresponding command: CTO
	% Configures the trigger output conditions for the given digital output line. Depending on the controller, the trigger output conditions will either become active immediately, or will become active when activated with PI_TRO().
	% Arguments:
	%  - ID ID of controller
 	%	 - piTriggerOutputIds is an array with the trigger output lines of the controller
	%  - piTriggerParameterArray is an array with the CTO parameter IDs
	%  - pdValueArray is an array of the values to which the CTO parameters are set
	%  - iArraySize is the size of the array piTriggerOutputIds
	% Returns:
	% 	TRUE if no error, FALSE otherwise (see p. 10)

	if strcmp(polarity, 'pos')
		polVal = 1; % active high
	elseif strcmp(polarity, 'neg')
		polVal = 0; % active low 
	else
		error('invalid polarity mode passed');
	end 

	nDelay = round(pulseWidth / 33.3e-3);

	piTriggerOutputIds = int32(ones(1, 6, 'int32') * outputChannel);
	piTriggerParameterArray = int32([2, 7, 3, 1, 9, 10]);
	pdValueArray = double([1, polVal, triggerMode, res, stopPos, startPos]);
	
	for iArray = 1:length(piTriggerOutputIds)
		ptrPiTriggerOutputIds = libpointer('int32Ptr', piTriggerOutputIds(iArray));
		ptrPiTriggerParameterArray = libpointer('int32Ptr', piTriggerParameterArray(iArray));
		ptrPdValueArray = libpointer('doublePtr', pdValueArray(iArray));
		
		noError = calllib(ps.LIB_ALIAS, 'PI_CTO', ...
			ps.ContrId, ... % ID of controller
			ptrPiTriggerOutputIds, ... % [int*]
			ptrPiTriggerParameterArray, ... % [int*]
			ptrPdValueArray, ... % [char*]
			int32(1)); % [int]
		
		if (noError == 0)
			ps.Read_Error();
	    error('[PiStage] Failed to set trigger!');
		end
	end



end  



%% TRIGGER MODES

% 0 = PositionDistance
% 			a trigger pulse is written whenever the axis has covered the 
%				TriggerStep distance (<CTOPam> ID 1). Optionally, values for 
% 			StartThreshold and StopThreshold (<CTOPam> IDs 8 and 9) can be defined
% 			to enable the trigger output for a limited position range and a certain
%				direction of motion only (negative or positive; Note: In case the motion
%				direction is reversed before the axis position has reached the stop 
%				threshold, trigger pulses will continue to be generated). When 
%				StartThreshold and StopThreshold are set to the same value, they will 
%				not be used.
% 2 = OnTarget; the on-target status of the selected axis is transferred to the selected digital output line (this status can also be read with the ONT? command).
% 5 = MotionError; the selected digital output line becomes active when a motion error occurs. The line will stay active until the error code is reset to 0 (by a query).
% 6 = InMotion; the selected digital output line is active as long as the selected axis is in motion (the in-motion state can also be read with #4, #5 or the SRG? command).

% 7 = Position+Offset
% 			the first trigger pulse is written when the axis has reached the position
% 			given by TriggerPosition (<CTOPam> ID 10). The next trigger pulses each
% 			are written when the axis position equals the sum of the last valid 
% 			trigger position and the step size given by TriggerStep (<CTOPam> ID 1).
% 			Trigger output ends when the axis position exceeds the value given by 
% 			StopThreshold (<CTOPam> ID 9). The sign of the TriggerStep value 
% 			determines for which direction of motion trigger pulses are to be output.
%				sTrigger processing is done by the DSP of the C863.
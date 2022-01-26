% File: Define_Trigger_Start.m @ PiStage
% Author: Urs Hofmann
% Mail: hofmannu@ethz.ch
% Date: 02.09.2021

% Description: 

function Define_Trigger_Stop(ps, stopPos, outputChannel)

	% translate into correct data format
	piTriggerOutputId = int32(outputChannel);
	piTriggerParameter = int32(9);
	piValueArray = double(stopPos);

	% extract pointers
	ptrPiTriggerOutputIds = libpointer('int32Ptr', piTriggerOutputId(1));
	ptrPiTriggerParameterArray = libpointer('int32Ptr', piTriggerParameter(1));
	ptrPdValueArray = libpointer('doublePtr', piValueArray(1));
	
	% call actual function
	noError = calllib(ps.LIB_ALIAS, 'PI_CTO', ...
		ps.ContrId, ... % ID of controller
		ptrPiTriggerOutputIds, ... % [int*]
		ptrPiTriggerParameterArray, ... % [int*]
		ptrPdValueArray, ... % [char*]
		int32(1)); % [int]
	
	% check if error occured
	if (noError == 0)
		ps.Read_Error();
    error('[PiStage] Failed to set start position of trigger!');
	end

end
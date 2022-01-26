% File: Define_Trigger_Mode.m @ PiStage
% Author: Urs Hofmann
% Mail: hofmannu@ethz.ch

function Define_Trigger_Mode(ps, trigMode, outputChannel)

	% TODO check if triggerMode is valid

	% translate into correct data format
	piTriggerOutputId = int32(outputChannel);
	piTriggerParameter = int32(3);
	piValueArray = double(trigMode);

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
    error('[PiStage] Failed to set trigger!');
	end

end
% File: Get_Available_IO.m @ PiStage
% Author: Urs Hofmann
% Mail: hofmannu@ethz.ch
% Date: 16.07.2021

% Description: returns the number of available input and output lines in device

function [iNInputs, iNOutputs] = Get_Available_IO(ps)

	iNInputs = zeros(1);
	iNOutputs = zeros(1);
	piNInputs = libpointer('int32Ptr',iNInputs);
	piNOutputs = libpointer('int32Ptr',iNOutputs);

	[bRet, iNInputs, iNOutputs] = calllib(ps.LIB_ALIAS, 'PI_qTIO', ps.ContrId, piNInputs, piNOutputs);

	if bRet == 0
		ps.Read_Error();
		error('Could not extract number of available input and outputs');
	end

end
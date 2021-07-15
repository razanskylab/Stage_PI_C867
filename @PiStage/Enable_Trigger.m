% File: Enable_Trigger.m @ PiStage
% Author: Urs Hofmann
% Mail: hofmannu@ethz.ch
% Date: 15.07.2021

% Description: enbales a trigger output

function Enable_Trigger(ps, varargin)

	% default function arguments
	outputChannel = 1;
	state = 1;

	% read in specific user arguments
	for (iargin = 1:2:(nargin-1))
		switch varargin{iargin}
			case 'outputChannel'
				outputChannel = varargin{iargin + 1};
			case 'state'
				state = varargin{iargin + 1};
			otherwise
				error('Invalid argument passed to function');
		end
	end

	% convert arguments into correct format
	outputChannel = int32(outputChannel);
	state = int32(state);

	% generate corresponding pointers
	ptrOutputChannel = libpointer('int32Ptr', outputChannel);
	ptrState = libpointer('int32Ptr', state);

	% turn trigger on
	noError = calllib(ps.LIB_ALIAS, 'PI_TRO', ...
		ps.ContrId, ... % ID of controller
		ptrOutputChannel, ptrState, int32(1));

	% check if everything went through smooth
	if (noError == 0)
		ps.Read_Error();
		error('[PiStage] Failed to enable trigger!');
	end

end
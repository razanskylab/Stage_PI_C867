% File: Read_Error.m @ PiStage
% Author: Urs Hofmann
% Mail: hofmannu@ethz.ch
% Date: 17.07.2021

% Description: Reads the latest error. If argument passed, analyzes it

function Read_Error(ps, varargin)

  if nargin == 1
  	[iErr] = calllib(ps.LIB_ALIAS,'PI_GetError',ps.ContrId);
  else
    iErr = varargin{1};
  end

  szAnswer = blanks(1001);
  [~, szAnswer] = calllib(ps.LIB_ALIAS, 'PI_TranslateError', iErr, szAnswer, 1000);
  
  if ~strcmp(szAnswer, 'No error')
    txtMsg = ['[PiStage] Error: ', szAnswer, '\n'];
    fprintf(txtMsg);
  else 
    fprintf("Actually no error occured");
  end

end
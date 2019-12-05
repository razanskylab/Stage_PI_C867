% File:     Set_Recorder_Trigger_Source.m @ PiStage
% Author:   Urs Hofmann
% Date:     27. Feb 2018
% Mail:     urshofmann@gmx.net

% Description: Defines a trigger source for a given data recorder table.

% Possible values for triggerSource:
% 0 - default setting, data recording is triggered with STE
% 1 - any command changing target position, e.g. Move
% 2 - next command, resets trigger after execution
% 6 - any command changing the target position, resets trigger after execution

function Set_Recorder_Trigger_Source(spi, recTableID, triggerSource)

  szAxes='1';
  pSzAxes = libpointer('cstring', szAxes);
  piValues1 = libpointer('int32Ptr', recTableID);
  piValues2 = libpointer('int32Ptr', triggerSource);
  iValues3 = int32(length(triggerSource));

  noError = calllib(...
    spi.LIB_ALIAS,'PI_DRT', ...
    spi.ContrId, ... % ID of the controller [int]
    piValues1, ... % ID of the record table [int*]
    piValues2, ... % ID of the trigger source [int*]
    pSzAxes, ... % dep. on trigger source, either dummy or ID of trig line [char*]
    iValues3); % size of piValues1, piValues2, and szValues [int]
  % Returns TRUE if no error, FALSE otherwise

  if ~noError
    [iErr] = calllib(spi.LIB_ALIAS,'PI_GetError',spi.ContrId);
    szAnswer = blanks(1001);
    [~,szAnswer] = calllib(spi.LIB_ALIAS,'PI_TranslateError',iErr,szAnswer,1000);
    if ~strcmp(szAnswer,'No error')
      short_warn(['[PiStage] Setting trigger failed: ',szAnswer]);
    end
    error('[PiStage] Failed to set Data Recorder Trigger Source (DRT)!');
  else
    fprintf('[PiStage] Set Data Recorder Trigger source.\n');
  end



end

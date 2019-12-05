% File:     Set_Data_Recorder_Configuration.m
% Date:     27. Feb 2018
% Author:   Urs Hofmann
% Version:  1.0

% Description: Set data recorder configuration. Determines the data source and
% the kind of data used for the given data recorder table.

% PI_DRC - Set Data Recorder Trigger Source

function Set_Data_Recorder_Configuration(spi, ch, mag)

  szAxes='1';

  for n = 1:length(ch) % for each channel
    iValues1 = ch(n); % ID of the record table [int]
    iValues2 = mag(n); % record option [int]
    pSzAxes = libpointer('cstring', szAxes);
    piValues1 = libpointer('int32Ptr',iValues1);
    piValues2 = libpointer('int32Ptr',iValues2);
    [bRet,~,szAxes,~] = calllib(...
      spi.LIB_ALIAS,...
      'PI_DRC',...
      spi.ContrId,... % ID of controller [int]
      piValues1,... % ID of the record table [int*]
      pSzAxes,... % ID of the record source e.g. axis no. or channel no. [char*]
      piValues2); % record option, i.e. the kind of data to be recorded [int*]

    % Check for errors
    if ~bRet
      [iErr] = calllib(spi.LIB_ALIAS,'PI_GetError',spi.ContrId);
      szAnswer = blanks(1001);
      [~,szAnswer] = calllib(spi.LIB_ALIAS,'PI_TranslateError',iErr,szAnswer,1000);
      if ~strcmp(szAnswer,'No error')
        short_warn(['[PiStage] Setting channel ' num2str(ch(n)) ' failed: ',szAnswer]);
      end
      error('[PiStage] Error while setting data recorder configuration.');
    else
      [iErr] = calllib(spi.LIB_ALIAS,'PI_GetError',spi.ContrId);
      szAnswer = blanks(1001);
      [~,szAnswer] = calllib(spi.LIB_ALIAS,'PI_TranslateError',iErr,szAnswer,1000);
      if ~strcmp(szAnswer,'No error')
        short_warn(['[PiStage] Setting channel ' num2str(ch(n)) ' failed: ',szAnswer]);
      else
        fprintf('[PiStage] Successfully set data recorder configuration.\n');
      end
    end
    clear piValues1 piValues2;
  end

end

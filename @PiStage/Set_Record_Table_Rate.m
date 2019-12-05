% File:     Set_Record_Table_Rate.m @ PiStage
% Author:   Urs Hofmann
% Date:     27. Feb 2018
% Mail:     urshofmann@gmx.net

% Description: Sets the record table rate of the pi rate to recordtablerate

function Set_Record_Table_Rate(spi, recordtablerate)

  noError = calllib(spi.LIB_ALIAS, 'PI_RTR', spi.ContrId, recordtablerate);

  if ~noError
    fprintf('[PiStage] Could not set recordtablerate.\n');
  end

  % Recheck for error
  [iErr] = calllib(spi.LIB_ALIAS,'PI_GetError',spi.ContrId);
  szAnswer = blanks(1001);
  [~,szAnswer] = calllib(spi.LIB_ALIAS,'PI_TranslateError',iErr,szAnswer,1000);
  if ~strcmp(szAnswer,'No error')
    short_warn(['Setting record rate failed: ', szAnswer]);
  else
    fprintf(['[PiStage] RecordTableRate set to ', num2str(recordtablerate), '.\n']);
  end

end

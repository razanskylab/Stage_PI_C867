function Macro_Run(spi,macroName,nRuns)

  noError = calllib(spi.LIB_ALIAS,'PI_MAC_NSTART',spi.ContrId,macroName,nRuns);

  % Check for errors
  if ~noError
      error('[PiStage] Error running macro');
  else
      if ~spi.beSilent
        fprintf(['[PiStage] Running macro ', macroName, '.\n']);
      end
      %FIXME check where macro is used and if there should be a wait here.
  end
end

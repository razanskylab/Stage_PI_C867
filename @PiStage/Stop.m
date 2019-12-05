function [] = Stop(spi)
  % Stops the motion of all axes instantaneously. Sets error code to 10.
  % PI_STP() also stops macros. After the axes are stopped, their target
  % positions are set to their current positions.
  short_warn('[PiStage] Stopping all stage movement! You really shouldn''t do this!');
  successful = calllib(spi.LIB_ALIAS,'PI_STP',spi.ContrId);
  if ~successful
    error('[PiStage] The stage is out of control! Everyman for himself!');
    % thank you Jake!
  end
end

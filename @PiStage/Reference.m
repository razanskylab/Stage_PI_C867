function Reference(spi)
  if spi.IsReferenced
    % short_warn('Stage was already referenced. I am not doing that again!');
    % dont ref again if stage is already referenced
  else
    fprintf('[PiStage] Referencing stage...')
    calllib(spi.LIB_ALIAS,'PI_FRF',spi.ContrId,spi.Axis);
    spi.Wait_Ready;
    fprintf('done!\n')
  end

end

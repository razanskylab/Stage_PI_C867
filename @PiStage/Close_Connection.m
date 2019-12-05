function [] = Close_Connection(spi)

  if ~spi.beSilent
    fprintf('[PiStage] Disconnecting.\n')
  end

  calllib(spi.LIB_ALIAS,'PI_CloseConnection',spi.ContrId);

end

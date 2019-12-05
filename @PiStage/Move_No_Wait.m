function Move_No_Wait(pi, pos)

	if (pos > spi.MAX_POS) || (pos < spi.MIN_POS)
    warning('Can''t move to position %2.1f mm.', pos);
  else
    %FIXME: check if error return actually works
    [noError,~,~] = calllib(spi.LIB_ALIAS,'PI_MOV', spi.ContrId, spi.Axis, pos);
  end
  
end
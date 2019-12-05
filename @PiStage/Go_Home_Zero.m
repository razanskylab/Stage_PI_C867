function Go_Home_Zero(spi)
  % Move all axes in szAxes to their home positions (is equivalent to moving
  % the axes to positions 0 using PI_MOV()). Depending on the controller, the
  % definition of the home position can be changed with PI_DFH().
  [noError,~] =  calllib(spi.LIB_ALIAS,'PI_GOH',spi.ContrId,spi.Axis);
  if ~noError
    error('Error calling Go_Home_Zero');
  end
  spi.Wait_Move;
end

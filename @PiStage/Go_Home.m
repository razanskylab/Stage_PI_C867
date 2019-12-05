function Go_Home(spi)
  % Move all axes in szAxes to their home positions (is equivalent to moving
  % the axes to positions 0 using PI_MOV()). Depending on the controller, the
  % definition of the home position can be changed with PI_DFH().
  spi.pos = spi.HOME_POS;
end

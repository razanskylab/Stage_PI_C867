% File:     Wait_Move.m @ PiStage
% Author:   Johannes Rebling, modified by Urs Hofmann
% Date:     27. Feb 2018
% Mail:     urshofmann@gmx.net

% Description: Function only returns when Pi Stage stoped moving.

function [] = Wait_Move(spi)

  % Create libpointer
  moving_= libpointer('int32Ptr', 1);

  % Wait unitl Pi is not moving anymore
  while(moving_.Value>0)
    calllib(spi.LIB_ALIAS,'PI_IsMoving',spi.ContrId,spi.Axis,moving_);
  end

end

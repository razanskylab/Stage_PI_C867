function [] = Wait_Ready(spi)
  ready = 0;
  ready_= libpointer('int32Ptr',ready);
  while(~ready_.value)
    calllib(spi.LIB_ALIAS,'PI_IsControllerReady',spi.ContrId,ready_);
  end
end

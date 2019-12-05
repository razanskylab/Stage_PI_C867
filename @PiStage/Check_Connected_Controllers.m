function Check_Connected_Controllers(spi)
  % check if any controller are already connected
  % if so, use that controller instead of trying to connect again...
  anyConnect = false;
  connectedIDs = [];
  for iD = 0:spi.MAX_ID_CHECK
    if calllib(spi.LIB_ALIAS,'PI_IsConnected',iD)
      anyConnect = true;
      connectedIDs(end+1) = iD;
    end
  end
  spi.AnyControllerConnected = anyConnect;
  spi.ConnectedIDs = connectedIDs;
end

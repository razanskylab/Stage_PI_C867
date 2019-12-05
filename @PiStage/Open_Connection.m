function [isConnected] = Open_Connection(spi)

  spi.isConnected = false;
  isConnected = false;
  useOld = false;

  % check if any controller is already connected and use that one if it is
  spi.Check_Connected_Controllers;
  if (spi.AnyControllerConnected && numel(spi.ConnectedIDs)==1)

    if ~spi.beSilent
      fprintf('[PiStage] Using already connected PI stage controller!\n');
    end

    spi.ContrId = spi.ConnectedIDs;
    useOld = true;

  elseif spi.AnyControllerConnected

    fprintf('\n Something smells very fishy here!\n');
    fprintf('I found %i connected PI controllers!',numel(spi.ConnectedIDs));
    error('Can''t have more then one PI controller with this shitty software!');
  else
    fprintf('[PiStage] Connecting to stage controller.\n');
    % No controller connected, try to establish connection...
    spi.EnumerateUSB;
    spi.ContrId = calllib(spi.LIB_ALIAS,'PI_ConnectUSB',spi.StageDescription);
    if (spi.ContrId < 0)
      fprintf('[PiStage] Connecting failed.\n');
    end
  end

  % get axis here as well!
  axis = blanks(10); % prepare buffer
  [noError,axis] = calllib(spi.LIB_ALIAS,'PI_qSAI',spi.ContrId,axis,10);
  spi.Axis = axis(1);

  if ~noError
    error('[PiStage] Error reading axis identifiers!')
  end

  % check for successful connection
  if spi.isConnected && noError && ~useOld
    if ~spi.beSilent
      fprintf('[PiStage] Connection established.\n');
    end
  elseif spi.isConnected && noError
    % all good...do nothing
  else
    fprintf('failed :-( !\n');
  end
end

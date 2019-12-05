function [LIB_ALIAS,stageID,piezoAxis] = piezoInitStage(velocity)
  % [LIB_ALIAS,stageID,piezoAxis] = piezoInitStage(velocity)
  % Installer for the dlls and the programing manual can be found at
  % http://www.physikinstrumente.net/ftpservice/
  % UserName: service  Password: ftp-pi

  %% Load Libs -------------------------------------------------------------------
  fprintf('Loading PI stage library...');
  % using protoype file makes loading A LOT faster
  LIB_ALIAS = 'PI';
  LIB_NAME = 'PI_GCS2_DLL_x64.dll';
  [notfound,warnings] = loadlibrary(LIB_NAME,@pi_protype_file,'alias',LIB_ALIAS);
  %FIXME do something in case there were warnings...
  fprintf('done!\n');

  %% Connect and check connection ------------------------------------------------
  fprintf('Connecting to stage controller...');
  enumerateUSB = blanks(1000);
  stageID = calllib(LIB_ALIAS,'PI_ConnectUSB',enumerateUSB);
  if (stageID < 0) % stage either already connected or it doesn't exist...
    fprintf('failed! Was stage already connected?\n');
    fprintf('Unloading and loading libraries again...');
    unloadlibrary(LIB_ALIAS);
    warning off
    [notfound,warnings] = loadlibrary(LIB_NAME,@pi_protype_file,'alias',LIB_ALIAS);
    warning on
    fprintf('done!\n');
    fprintf('Trying to connect to stage controller...');
    [~,enumerateUSB] = calllib(LIB_ALIAS,'PI_EnumerateUSB',enumerateUSB,1000,'C-867');
  else
    [~,enumerateUSB] = calllib(LIB_ALIAS,'PI_EnumerateUSB',enumerateUSB,1000,'C-867');
  end;

  stageID = calllib(LIB_ALIAS,'PI_ConnectUSB',enumerateUSB);
  if(stageID<0)
    warningText = sprintf('Stage stageID was %i but should be bigger than 0!',stageID);
    short_warn(warningText);
    fprintf('failed!\n');
    error('Could not connect to controller.');
  end

  % preload return variable
  % idn = blanks(100);
  % query Identification string
  % [~,idn] = calllib(LIB_ALIAS,'PI_qIDN',stageID,idn,100);
  % fprintf('Connected to %s\n',idn);

  % query connected piezoAxis
  piezoAxis = blanks(10);
  [~,piezoAxis] = calllib(LIB_ALIAS,'PI_qSAI',stageID,piezoAxis,10);
  piezoAxis = piezoAxis(1);

  fprintf('done!\n');


  %% Switch on Servo --------------------------------------------------------------
  fprintf('Switching on servo...');
  % query servo state
  svo = zeros(size(piezoAxis));
  [~,piezoAxis,~] = calllib(LIB_ALIAS,'PI_qSVO',stageID,piezoAxis,svo);

  % set servo state to on
  svo = ones(size(piezoAxis));
  psvo = libpointer('int32Ptr',svo);
  calllib(LIB_ALIAS,'PI_SVO',stageID,piezoAxis,psvo);
  fprintf('done!\n');

  %% set velocity of stage -------------------------------------------------------
  fprintf('Setting stage velocity to %2.2f mm/s...',velocity);
  calllib(LIB_ALIAS,'PI_VEL',stageID,piezoAxis,velocity);
  fprintf('done!\n');

  %% reference stage -------------------------------------------------------------
  fprintf('Referencing stage...');
  calllib(LIB_ALIAS,'PI_FRF',stageID,piezoAxis);
  ready = 0;
  pReady = libpointer('int32Ptr',ready);
  while(~ready)
    [~,ready] = calllib(LIB_ALIAS,'PI_IsControllerReady',stageID,pReady);
  end
  fprintf('done!\n');

  %% run the PI macro ------------------------------------------------------------
  calllib(LIB_ALIAS,'PI_MAC_NSTART',stageID,'PIMACRO',1);
end

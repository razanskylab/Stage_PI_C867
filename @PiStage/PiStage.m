classdef PiStage < handle
  % driver class for the PI linear piezo stage
  % stage type M-683 Linear Stage
  % see pi_stages.md file in the wiki for details on the stage
  %
  % 04/2016 - Johannes Rebling (johannesrebling@gmail.com)

  properties % default properties, probably most of your data
    vel double {mustBePositive}; % [mm/s]
    pos double {mustBeNonnegative}; % absolute position relative to home
    acc double {mustBePositive};
    beSilent = 0;
  end

  properties (Constant, Access=public)
    HOME_POS = 41.5; %[mm]
    LIB_ALIAS = 'PI';
  end

  properties (Constant, Hidden=true)
  % can only be changed here in the def file,
  % can't be seen but spi.PropertyName will give result
    MIN_STEP_SIZE = 0.3 * 1e-3; % [mm] = 300 nm
    STEP_SIZE_RESOLUTION = 0.1 * 1e-3; % [mm] = 100 nm
    MAX_POS = 50; % [mm]
    MIN_POS = 0; % [mm]
    MAX_VEL = 350; % [mm/s]
    CONNECT_ON_STARTUP = true;
    LIB_NAME = 'PI_GCS2_DLL_x64.dll';
    LIB_PATH = 'C:\Users\Public\PI\PI_Programming_Files_PI_GCS2_DLL\';
    PTYPE_FILE = 'PI_GCS2_DLL.h';
    MAX_ID_CHECK = 20; %check if ID=0:MAX_ID_CHECK controllers connected
    DEFAULT_VEL = 100;
    DEFAULT_ACC = 1000;
  end

  properties (SetAccess=private)
  %can only be set by methods within this class but can be seen
    ErrorId;
    ServoOn;
    isConnected = 0;
    IsReferenced = 0;
    Axis;
    ContrId;
  end

  properties (Dependent, Hidden=true) %callulated based on other values
    TRAVEL_RANGE;
  end

  properties (Access=private) %can only be set and seen by methods within this class
    AnyControllerConnected;
    ConnectedIDs;
    StageDescription;
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% "Standard" methods, i.e. functions which can be called by the user and by
  % the class itself
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function spi = PiStage(~,doConnect)
      % constructor, called when creating instance of this class
      switch nargin
      case 1
        % doConnect = doConnect
      case 0
        doConnect = spi.CONNECT_ON_STARTUP; % use default setting
      otherwise
        short_warn('[PiStage] Wrong number of input arguemnts. Using default settings!');
      end

      spi.Load_Lib;
      % connect to stage on startup
      if doConnect
        spi.Open_Connection;
        spi.Switch_On_Servo;
        if ~spi.IsReferenced
          spi.Reference;
        end
        spi.vel = spi.DEFAULT_VEL;
        spi.acc = spi.DEFAULT_ACC;
      else
        short_warn('[PiStage] Class created but not connected to stage yet.')
        fprintf('Use .Connect and .Reference before you can use other methods.')
      end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function saveObj = saveobj(spi)
      % only save public properties of the class if you save it to mat file
      % without this saveobj function you will create an error when trying
      % to save this class
      saveObj.vel = spi.vel;
      saveObj.pos = spi.pos;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function delete(spi)
      % Close_Connection from stage if connected
      if spi.isConnected
        spi.Close_Connection;
      end

      % unload library if it is loaded
      if libisloaded(spi.LIB_ALIAS)
        unloadlibrary(spi.LIB_ALIAS);
      end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Property Set & Get functions are down here...
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function tr = get.TRAVEL_RANGE(spi)
      tr = spi.MAX_POS - spi.MIN_POS;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function vel = get.vel(spi)
      % Gets the velocity value commanded with PI_VEL() for szAxes.
      vel = 0;
      vel_= libpointer('doublePtr',vel);
      [~] = calllib(spi.LIB_ALIAS,'PI_qVEL',spi.ContrId,spi.Axis,vel_);
      vel = vel_.value;
      %FIXME make sure units are correct!
    end
    %===========================================================================
    function set.vel(spi, vel)
      if (vel>spi.MAX_VEL)
        short_warn('[PiStage] Velocity to high! Sloth and steady wins the race!');
        short_warn('[PiStage] Setting it to the default speed instead!');
        vel = spi.DEFAULT_VEL;
      end
      calllib(spi.LIB_ALIAS,'PI_VEL',spi.ContrId, spi.Axis, vel);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function acc = get.acc(spi)
      % Gets the accocity value commanded with PI_VEL() for szAxes.
      acc = 0;
      acc_= libpointer('doublePtr',acc);
      [ret] = calllib(spi.LIB_ALIAS,'PI_qACC',spi.ContrId,spi.Axis,acc_);
      acc = acc_.value;
      %FIXME make sure units are correct!
    end
    %===========================================================================
    function set.acc(spi, acc)
      % Set the acceleration to use during moves of szAxes. The PI_ACC() setting
      % only takes effect when the given axis is in closed-loop operation (servo
      % on).
      % if (acc>spi.MAX_VEL)
      %   short_warn('Velocity to high! Sloth and steady wins the race!');
      %   short_warn('Setting it to the default speed instead!');
      %   acc = spi.DEFAULT_VEL;
      % end
      calllib(spi.LIB_ALIAS,'PI_ACC',spi.ContrId,spi.Axis,acc);
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function pos = get.pos(spi)
      % Get the current positions of selected axis.
      pos = 0;
      pos_= libpointer('doublePtr',pos);
      [~] = calllib(spi.LIB_ALIAS,'PI_qPOS',spi.ContrId,spi.Axis,pos_);
      pos = pos_.value;
      %FIXME make sure units are correct!
    end
    % %===========================================================================
    function set.pos(spi, pos)
      % Move szAxes to specified absolute positions. Axes will start moving to the
      % new positions if ALL given targets are within the allowed ranges and ALL
      % axes can move. All axes start moving simultaneously. Servo must be enabled
      % for all commanded axes prior to using this command.
      if (pos > spi.MAX_POS) || (pos < spi.MIN_POS)
        short_warn(sprintf('Can''t move to position %2.1f mm.', pos));
        short_warn('Position is out of my allowed movement range!');
        short_warn('I do not ask you to jump up 10 m do I? You are always so mean :,-(');
      else
        %FIXME: check if error return actually works
        [noError,~,~] = calllib(spi.LIB_ALIAS,'PI_MOV', spi.ContrId, spi.Axis, pos);
        spi.Wait_Move;
      end
    end

    function Move_No_Wait(spi, pos)
      % Move szAxes to specified absolute positions. Axes will start moving to the
      % new positions if ALL given targets are within the allowed ranges and ALL
      % axes can move. All axes start moving simultaneously. Servo must be enabled
      % for all commanded axes prior to using this command.
      if (pos > spi.MAX_POS) || (pos < spi.MIN_POS)
        short_warn(sprintf('Can''t move to position %2.1f mm.', pos));
        short_warn('Position is out of my allowed movement range!');
        short_warn('I do not ask you to jump up 10 m do I? You are always so mean :,-(');
      else
        %FIXME: check if error return actually works
        [noError,~,~] = calllib(spi.LIB_ALIAS,'PI_MOV', spi.ContrId, spi.Axis, pos);
      end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function errorId = get.ErrorId(spi)
      errorId = calllib(spi.LIB_ALIAS,'PI_GetError',spi.ContrId);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function servoOn = get.ServoOn(spi)
      % Get the servo-control mode (on = closed loop, off = open loop) for szAxes
      servoOn = false;
      [noError,axis,servoOn] = ...
        calllib(spi.LIB_ALIAS,'PI_qSVO',spi.ContrId,spi.Axis,servoOn);
      %FIXME why is Axis an putput here?
      if ~noError
        error('[PiStage] Error reading axis identifiers!')
      end
    end
    % %===========================================================================
    function set.ServoOn(spi, state)
      state = libpointer('int32Ptr',state);
      %FIXME check if that lib is really needed
      calllib(spi.LIB_ALIAS,'PI_SVO',spi.ContrId,spi.Axis,state);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function isReferenced = get.IsReferenced(spi)
      % Get the servo-control mode (on = closed loop, off = open loop) for szAxes
      isReferenced = 0;
      ref_= libpointer('int32Ptr', isReferenced);
      [noError] = calllib(spi.LIB_ALIAS, 'PI_qFRF', spi.ContrId,spi.Axis,ref_);
      if ~noError
        error('Error in get.IsReferenced!')
      else
        isReferenced = double(ref_.value); % convert back to default double value...
      end

    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function isConnected = get.isConnected(spi)
      % Get the servo-control mode (on = closed loop, off = open loop) for szAxes
      isConnected = calllib(spi.LIB_ALIAS, 'PI_IsConnected', spi.ContrId);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Depedent properties get functions
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % function countsPerMM = get.CountsPerMM(spi)
    %   countsPerMM = round(spi.GEAR_RATIO*spi.COUNTER_RES*spi.ROT_TO_TRANS);
    % end

  end
end
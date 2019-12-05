% File:     Read_Position_Data.m @ PiStage
% Author:   Unknown, modified by Urs Hofmann
% Date:     27. Jan 2018
% Mail:     urshofmann@gmx.net

% Description: Function reads out the positions stored in the Pi Stage interal
% memory. The structure of the output matrix is
%   stagePosData(:,1): time vector in s
%   stagePosData(:,2): Commanded position of the axis
%   stagePosData(:,3): Actual position of the axis

% Input:
%
%   recTableID: ID of table which we want to read out
%   nDataPoints: Number of datapoints we want to read out

% FIXME: Seems not to work yet

function [stagePosData] = Read_Position_Data(spi, iTables, nDataPoints)

  fprintf('[PiStage] Reading back position.\n');

  % Limit read out to data recorder size to wN = 8192
  wN = 8192;
  if(nDataPoints > wN)
    fprintf('[PiStage] Limiting the readout to 8192 datapoints.\n');
    nDataPoints = int32(wN);
  else
    nDataPoints = int32(nDataPoints);
  end

  piTables = libpointer('int32Ptr', iTables); % [int*]
  nTables = length(iTables); % [int]
  fprintf(['[PiStage] Number of tables to read: ', num2str(nTables),'.\n']);
  hlen = 1000;
  header = blanks(hlen+1);
  ppdData = libpointer('doublePtrPtr', zeros(nDataPoints, nTables)); % [double**]

  fprintf(['[PiStage] Number of samples to read: ', num2str(nDataPoints), '.\n']);

  % Read data record tables. This function reads the data asynchronously, it
  % will return as soon as the data header has been read and start a background
  % process which reads the data itself. See PI_GetAsyncBufferIndex.
  noError = calllib(...
      spi.LIB_ALIAS, ...
      'PI_qDRR', ...
      spi.ContrId, ... % ID of controller [int]
      piTables, ... % IDs of data record tables [int*]
      nTables, ... % number of record tables to read [int]
      1, ... % index of first value to read (starts with index 1) [int]
      nDataPoints, ... % number of values to read [int]
      ppdData, ... % pointer to internal array to store the data [double**]
      header, ... % buffer to store the GCS array header [char*]
      hlen); % size of the buffer to store the GCS array header [int]
  % returns TRUE if successfull, FALSE otherwise

  % Check for error
  if ~noError

    [iErr] = calllib(spi.LIB_ALIAS,'PI_GetError',spi.ContrId);
    szAnswer = blanks(1001);
    [~,szAnswer] = calllib(spi.LIB_ALIAS,'PI_TranslateError',iErr,szAnswer,1000);
    if ~strcmp(szAnswer,'No error')
      short_warn(['Error while reading out data: ', szAnswer]);
    end

    error('[PiStage] Error reading out recorded position data.');
  end

  nIdx = (nTables * nDataPoints - 1); % number of values to read

  idx = 0;
  while idx < nIdx % while not read completely
    idx = calllib(spi.LIB_ALIAS,'PI_GetAsyncBufferIndex',spi.ContrId);
    % Returns -1 if something went wrong

    % Check if data is available, if not abort
    if (idx == -1)
      error('[PiStage] Failed to read back stage position. No data available.');
    end

  end

%  setdatatype(ppdData,'doublePtr',nTables,nDataPoints);

  % Convert pointer to actual value in matlab
  stagePosData = double(ppdData.Value);
  stagePosData = [stagePosData(:,1); stagePosData(:,2)];


end

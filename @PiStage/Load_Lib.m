% File: Load_Lib.m @ PiStage
% Author: Urs Hofmann
% Mail: hofmannu@biomed.ee.ethz.ch
% Date: 20-Jan-2020

function Load_Lib(spi)

  % Only load library if it is not loaded yet
  if(~libisloaded(spi.LIB_ALIAS))

    if ~spi.beSilent
      fprintf('[PiStage] Loading library.\n');
    end

    % using protoype file makes loading A LOT faster
    libPath = [spi.LIB_PATH, spi.LIB_NAME];
    headerPath = [spi.LIB_PATH, spi.PTYPE_FILE];
    [notfound, warnings] = loadlibrary(...
      libPath, ...
      headerPath, ...
      'alias', spi.LIB_ALIAS);
        % [spi.LIB_PATH, spi.PTYPE_FILE], ...

  else

    if ~spi.beSilent
      fprintf('[PiStage] Library already loaded.\n');
    end

  end

end

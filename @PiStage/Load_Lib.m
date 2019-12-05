function Load_Lib(spi)

  % Only load library if it is not loaded yet
  if(~libisloaded(spi.LIB_ALIAS))

    if ~spi.beSilent
      fprintf('[PiStage] Loading library.\n');
    end

    % using protoype file makes loading A LOT faster
    [notfound, warnings] = ...
      loadlibrary([spi.LIB_PATH, spi.LIB_NAME], [spi.LIB_PATH, spi.PTYPE_FILE], 'alias',spi.LIB_ALIAS);

  else

    if ~spi.beSilent
      fprintf('[PiStage] Library already loaded.\n');
    end

  end

  % show function arguments with libfunctionsview(LIB_ALIAS);
end

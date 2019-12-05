function EnumerateUSB(spi)
  % preallocate memory for stageDescription string
  bufferSize = 200;
  stageDescription = blanks(bufferSize);
  [~,stageDescription] = ...
    calllib(spi.LIB_ALIAS,'PI_EnumerateUSB',stageDescription,bufferSize,'C-867');
  spi.StageDescription = stageDescription;
end

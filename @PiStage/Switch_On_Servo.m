function Switch_On_Servo(spi)

  % Get the servo-control mode for spi.Axis
  if spi.ServoOn
    % fprintf('Servo already on!\n');
  else
    fprintf('[PiStage] Switch on servo.\n');
    spi.ServoOn = true;
    %fprintf('done!\n');
  end
end

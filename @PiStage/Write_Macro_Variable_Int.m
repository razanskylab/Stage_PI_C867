function Write_Macro_Variable_Int(PI, variable, value)

  fprintf(['[PiStage] Write variable ', variable, '.\n']);

  varValueString = sprintf('%1.0f',value);

  ret = calllib(PI.LIB_ALIAS,'PI_VAR',PI.ContrId,variable,varValueString);
  if ~ret
      error('[PI] Failed to set PI controller variable!');
  end

end

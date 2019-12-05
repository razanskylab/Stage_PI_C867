function Mov_Rel(spi,distance)
    newPos = distance + spi.pos;
    if (newPos > spi.MAX_POS) || (newPos < spi.MIN_POS)
        short_warn(sprintf('Can''t move to position %2.1f mm.',newPos));
        short_warn('Position is out of my allowed movement range!');
        short_warn('I don''t ask you to jump up 10 m do I? You are always so mean :,-(');
    else
        %FIXME: check if error return actually works
        [noError,~,~] = calllib(spi.LIB_ALIAS,'PI_MVR',spi.ContrId,spi.Axis,distance);
        spi.Wait_Move;
        %FIXME better to spi.Wait_Ready here?
    end
end

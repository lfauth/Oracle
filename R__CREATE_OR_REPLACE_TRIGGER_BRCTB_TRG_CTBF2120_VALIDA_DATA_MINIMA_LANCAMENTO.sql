CREATE OR REPLACE TRIGGER BRCTB.TRG_CTBF2120_VALIDA_DATA_MINIMA_LANCAMENTO
  BEFORE UPDATE 
    OF DT_MINIMA_LANCTO_CONTABIL
    ON DOM_PARAMETRO_DOMCTB
  FOR EACH ROW
BEGIN
  IF UPDATING THEN
    IF :NEW.DT_MINIMA_LANCTO_CONTABIL <> :OLD.DT_MINIMA_LANCTO_CONTABIL THEN
      :NEW.USUARIO_ALTERACAO := USER;
      :NEW.DT_ALTERACAO := SYSDATE;
    END IF;
  END IF;
END TRG_CTBF2120_VALIDA_DATA_MINIMA_LANCAMENTO;
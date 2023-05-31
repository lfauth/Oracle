PACKAGE PCK_REPORT IS
  
   function getReportName return varchar2;
   function ExtensaoArquivo return varchar2;
   procedure setReportName( p_report_name in varchar2 );
   procedure AdicionaParametro( p_parametro in varchar2, p_valor in varchar2, p_data_parameter boolean := false );
   procedure AdicionaParametrosDefault;
   procedure RemoveParametro( p_parametro in varchar2 := null );
   procedure generate;
   
END;
/*******************************************
   Code modified by the Forms Migration Assistant
   05-Feb-2019 01:50 PM
 *******************************************/

/*******************************************
   Code modified by the Forms Migration Assistant
   05-Feb-2019 01:50 PM
 *******************************************/

PACKAGE BODY PCK_REPORT IS
   
   type t_rec_parametros is record (
      nome varchar2(32000),
      valor varchar2(32000),
      tipo number);
      
   type t_tabela_parametros is table of t_rec_parametros index by binary_integer ;

   t_parametros t_tabela_parametros;
   v_report_name long;
   v_report_file_name long;
   
   -- diretorioExecutavel
   function diretorioExecutavel return varchar2 is
     v_path   varchar2 (255);
   begin
      v_path := get_form_property ( :System.Current_Form, File_Name);
      v_path := substr (v_path, 1, instr (v_path, '\', -1));
      return (v_path);
   end diretorioExecutavel;

   -- setReportName
   procedure setReportName( p_report_name in varchar2 ) is
   begin
      v_report_name := p_report_name;
      v_report_file_name := diretorioExecutavel||p_report_name;	      	
   end setReportName;
   
   -- getReportName
   function getReportName return varchar2 is
   begin
      if ( v_report_name is null )
      then
         v_report_name := get_application_property( CURRENT_FORM_NAME );
      end if;
      
			if ( instr( v_report_name, '.', -1 ) > 0 )
			then -- retira a extensao    
         return( rtrim( substr( v_report_name, 1, instr( v_report_name, '.', -1 )-1 ) ));	
			else
				 return( v_report_name );
		  end if;
   end getReportName;
   
   -- AdicionaParametro
   procedure AdicionaParametro( p_parametro in varchar2, p_valor in varchar2, p_data_parameter boolean := false ) is
      vSeq binary_integer;
      vTipoParametro number;
   begin
     if ( p_parametro is not null )
     then
			  if ( p_data_parameter )
			  then
			     vTipoParametro := DATA_PARAMETER;
			  else
			     vTipoParametro := TEXT_PARAMETER;
			  end if;

        vSeq := t_parametros.first;
        while( vSeq is not null ) loop
     	     if ( t_parametros( vSeq ).nome = p_parametro )
     	     then
     	        t_parametros( vSeq ).valor := p_valor;
     	        t_parametros( vSeq ).tipo := vTipoParametro;
     	        return;
     	     end if;
     	     vSeq := t_parametros.next( vSeq );
        end loop;
        
        vSeq  := t_parametros.count;
        t_parametros( vSeq ).nome := p_parametro;
        t_parametros( vSeq ).valor := p_valor;
     	  t_parametros( vSeq ).tipo := vTipoParametro;        
     end if;
   end AdicionaParametro;

   -- RemoveParametro
   procedure RemoveParametro( p_parametro in varchar2 := null ) is
      vSeq binary_integer;
   begin
      if ( p_parametro is null )   	
      then
         t_parametros.delete;
      else
         vSeq := t_parametros.first;
         while ( vSeq is not null ) loop
            if ( t_parametros( vSeq ).nome = p_parametro )
            then
               t_parametros.delete( vSeq );
               return;
            end if;
         end loop;
      end if;	
   end RemoveParametro;

	 -- AdicionaParametrosDefaultFom 
	 procedure AdicionaParametrosDefault is
      v_printer_name varchar2(1000);
      v_printer_port varchar2(1000);
   begin

	    adicionaParametro( 'PARAMFORM', 'NO' );
	    adicionaParametro( 'ORACLE_SHUTDOWN', 'YES' );
			adicionaParametro( 'DESTYPE', nvl( :b_parametros.destino, 'PREVIEW' ) );
			adicionaParametro( 'DESFORMAT', nvl( :b_parametros.formato, 'PDF' ) );
	 	
	 end AdicionaParametrosDefault;


   -- Generate
   procedure generate is
     p_list paramlist;
     p_list_name varchar2(100) := 'lista_parametros';
     vSeq binary_integer;
     
	   --
     procedure carregaParametros is
     begin
    	   p_list := get_parameter_list( p_list_name );	
    	   
    	   if ( not id_null( p_list ) )
    	   then
    	      destroy_parameter_list( p_list );
    	   end if;

    	   p_list := FORMSUP.CREATE_PARAMETER_LIST_FORMSUP( p_list_name );     	
    	   
     	   vSeq := t_parametros.first;
     	   while ( vSeq is not null ) loop
     	      FORMSUP.ADD_PARAMETER_FORMSUP( p_list
     	      							,t_parametros( vSeq ).nome 
     	      						  ,t_parametros( vSeq ).tipo
     	      						  ,t_parametros( vSeq ).valor  );
     	      						  
     	      vSeq := t_parametros.next( vSeq );
     	   end loop;
     end carregaParametros;
     
     --
     procedure limpaParametros is
     begin
        destroy_parameter_list( p_list );	
     end limpaParametros;
     
   begin
      if ( getReportName is not null )
      then
    	  carregaParametros;

				set_application_property( CURSOR_STYLE, 'BUSY' );
				--MFUP-SINCRONIZA
 NULL;
				
				BEGIN				
           FORMSUP.RUN_PRODUCT_FORMSUP( REPORTS, v_report_file_name,  SYNCHRONOUS, RUNTIME, FILESYSTEM, p_list, null );
				EXCEPTION
					 WHEN OTHERS THEN
				      limpaParametros;
				      RemoveParametro();
					    set_application_property( CURSOR_STYLE, 'DEFAULT' );
					    msg_erro_case( SQLCODE || ' - '|| SQLERRM, 'E', TRUE );
			  END;
				
				limpaParametros; -- da parameter_list
				RemoveParametro(); -- da pl/table
			  set_application_property( CURSOR_STYLE, 'DEFAULT' );				
      else
      	 msg_erro_case( 'Nome do Report não foi definido.', 'E', true );
      end if;
   end generate;

   -- ExtensaoArquivo
	function ExtensaoArquivo return varchar2 is
  begin
	   if ( nvl(:b_parametros.formato, 'PDF') = 'PDF' )
	   then
	      return( '.pdf' );
	   elsif ( :b_parametros.formato = 'RTF' )
	   then
	      return( '.rtf' );
	   elsif ( :b_parametros.formato like 'HTML%' )
	   then
	      return( '.html' );
	   elsif ( :b_parametros.formato = 'XML' )
	   then
	      return( '.xml' );	      
	   elsif ( :b_parametros.formato = 'DELIMITED' )
	   then
	      return( '.csv' );
	   else
	   	  return( '.txt' );
	   end if;
  end ExtensaoArquivo;
  
BEGIN
	 removeParametro( null );
END;
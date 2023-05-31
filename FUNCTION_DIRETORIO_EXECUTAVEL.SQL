FUNCTION Diretorio_Executavel RETURN VARCHAR2 IS
  v_Path VARCHAR2(255);
BEGIN
	v_Path := Get_Form_Property(:System.Current_Form, File_Name);
	v_Path := SUBSTR(v_Path, 1, INSTR(v_Path, '\', -1));
  RETURN(v_Path);
END;
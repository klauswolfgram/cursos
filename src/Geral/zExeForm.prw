#Include 'Protheus.ch'
#Include 'ParmType.ch'

/*/{Protheus.doc} zExeForm
Rotina para execu��o de fun��es dentro do Protheus.
@type function
@author SigaMDI.net
@since 21/03/2018
@version 1.0
	@example
	u_zExeForm()
/*/

User Function zExeForm
	
	//-> Declara��o de vari�veis.
	Local bError 
	Local cGet1Frm := PadR("Ex.: u_NomeFuncao() ", 50)
	Local nOpc     := 0
	Local oDlg1Frm := Nil
	Local oSay1Frm := Nil
	Local oGet1Frm := Nil
	Local oBtn1Frm := Nil
	Local oBtn2Frm := Nil
	
	//-> Recupera e/ou define um bloco de c�digo para ser avaliado quando ocorrer um erro em tempo de execu��o.
	bError := ErrorBlock( {|e| cError := e:Description } ) //, Break(e) } )
	
	//-> Inicia sequencia.
	BEGIN SEQUENCE
	
		//-> Constru��o da interface.
		oDlg1Frm := MSDialog():New( 091, 232, 225, 574, "Executa F�rmulas" ,,, .F.,,,,,, .T.,,, .T. )
		
		//-> R�tulo. 
		oSay1Frm := TSay():New( 008 ,008 ,{ || "Informe a sua fun��o aqui:" } ,oDlg1Frm ,,,.F. ,.F. ,.F. ,.T. ,CLR_BLACK ,CLR_WHITE ,084 ,008 )
		
		//-> Campo.
		oGet1Frm := TGet():New( 020 ,008 ,{ | u | If( PCount() == 0 ,cGet1Frm ,cGet1Frm := u ) } ,oDlg1Frm ,150 ,008 ,'!@' ,,CLR_BLACK ,CLR_WHITE ,,,,.T. ,"" ,,,.F. ,.F. ,,.F. ,.F. ,"" ,"cGet1Frm" ,,)
		
		//-> Bot�es.
		oBtn1Frm := TButton():New( 040 ,008 ,"Executar" ,oDlg1Frm ,{ || nOpc := 1, oDlg1Frm:end() } ,037 ,012 ,,,,.T. ,,"" ,,,,.F. )
		oBtn2Frm := TButton():New( 040 ,120 ,"Sair"     ,oDlg1Frm ,{ || nOpc := 2, oDlg1Frm:end() } ,037 ,012 ,,,,.T. ,,"" ,,,,.F. )
		
		//-> Ativa��o da interface.
		oDlg1Frm:Activate( ,,,.T.)

		IF nOpc = 1

			IF .not. 'U_' $ cGet1Frm
				cGet1Frm := 'U_' + cGet1Frm
			EndIF		

			IF .not. '(' $ cGet1Frm
				cGet1Frm := AllTrim(cGet1Frm) + '()'
			EndIF

			&(cGet1Frm)				

		EndIF
	
	RECOVER
		
		//-> Recupera e apresenta o erro.
		ErrorBlock( bError )
		MsgStop( cError )
		
	END SEQUENCE
	
Return

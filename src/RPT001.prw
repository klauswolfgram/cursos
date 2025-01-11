#include 'totvs.ch'

/*/{Protheus.doc} RPT001
    Impressao de Lista de notas de entrada por CFOP + DATA + NUMERO + CLIFOR + LOJA.
    @type  User Function 
    @author user
    @since 01/03/2023
    @version 1.0
    /*/
User Function RPT001

    Private cPerg       := 'RPT001'
    Private cAliasSQL   := getNextAlias()
    Private cSQL        := ''

    //-- Processa o grupo de perguntas
    fnRptPer()

    IF .not. pergunte(cPerg)
        Return
    EndIF

    //-- Processa o relatorio
    fnRptDef()  
    
Return 

Static Function fnRptDef
	
    Local cReport 		:= cPerg
	Local cDesc			:= 'Lista de notas de entrada'
	Local cTitulo		:= 'Lista de notas de entrada'
	Local lPaisagem		:= .F.
	Local lTotInLine	:= .T. //-- Imprime celulas em linha
	Local lHeaderPage	:= .T. //-- Cabecalho da secao no topo da pagina
	Local lHeaderBreak	:= .T. //-- Imprime cabecalho na quebra da secao
	Local lPageBreak	:= .T. //-- Salta a pagina na mudanca de secao
	Local lLineBreak	:= .T. //-- Quebra a linha quando nao couber na secao
    Local bAction       := {||fnImpres()}

    Private oReport     := Nil
    Private oSection    := Nil
    Private oBreak      := Nil

	oReport             := tReport():new(cReport,cTitulo,cPerg,bAction,cDesc,lPaisagem)	
	oReport:setEnvironmet(2) 	//-- Ambiente: 1 - Servidor, 2 - Cliente
	oReport:setDevice(2)		//-- Tipo de impressao: 1 - Arquivo, 2 - Impressora, 3 - Email, 4 - Planilha e 5 - html   
    oReport:setLandScape(.T.)
    oReport:hideParamPage()

    oSection            := trSection():new(oReport,'Pedidos',cAliasSQL,,,,,lTotInLine,lHeaderPage,lHeaderBreak,lPageBreak,lLineBreak) 

	trCell():new(oSection,"D1_FILIAL"	,cAliasSQL,"Filial"		    ,,tamSX3('D1_FILIAL'    )[1])
    trCell():new(oSection,"D1_DOC"	    ,cAliasSQL,"Numero"         ,,tamSX3('D1_DOC'       )[1])  
    trCell():new(oSection,"D1_SERIE"	,cAliasSQL,"Serie"		    ,,tamSX3('D1_SERIE'	    )[1])
    trCell():new(oSection,"D1_ITEM"	    ,cAliasSQL,"Item"		    ,,tamSX3('D1_ITEM'	    )[1])
    trCell():new(oSection,"D1_EMISSAO"	,cAliasSQL,"Emissao"		,,tamSX3('D1_EMISSAO'	)[1])
    trCell():new(oSection,"A2_NOME"	    ,cAliasSQL,"Fornecedor"		,,tamSX3('A2_NOME'	    )[1],,{|| U_RPT001A()})
    trCell():new(oSection,"A2_EST"	    ,cAliasSQL,"UF"		        ,,tamSX3('A2_EST'	    )[1],,{|| __cRptUF   })     
    trCell():new(oSection,"D1_CF"	    ,cAliasSQL,"CFOP"		    ,,tamSX3('D1_CF'	    )[1])   
    trCell():new(oSection,"D1_TOTAL"	,cAliasSQL,"Valor"		    ,,tamSX3('D1_TOTAL'	    )[1]) 
    trCell():new(oSection,"D1_VALDESC"	,cAliasSQL,"Desconto"		,,tamSX3('D1_VALDESC'	)[1]) 
	trCell():new(oSection,"D1_BASEICM"	,cAliasSQL,"Base ICMS"		,,tamSX3('D1_BASEICM'   )[1])
	trCell():new(oSection,"D1_VALICM"	,cAliasSQL,"Valor ICMS"     ,,tamSX3('D1_VALICM'	)[1])  
    trCell():new(oSection,"D1_VALIPI"	,cAliasSQL,"Valor IPI"		,,tamSX3('D1_VALIPI'	)[1])  
    trCell():new(oSection,"D1_VALIMP6"	,cAliasSQL,"Valor PIS"		,,tamSX3('D1_VALIMP6'	)[1])  
    trCell():new(oSection,"D1_VALIMP5"	,cAliasSQL,"Vlr Cofins"		,,tamSX3('D1_VALIMP5'	)[1])  


    oBreak              := trBreak():new(oSection,{||(cAliasSQL)->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)}     ,"Total Nota",.F.,,.T.)

    trFunction():new(oSection:Cell("D1_TOTAL"  )	,NIL,"SUM"	        ,oBreak,NIL,NIL,NIL,.T.,.F.,.F.)
    trFunction():new(oSection:Cell("D1_VALICM" )	,NIL,"SUM"	        ,oBreak,NIL,NIL,NIL,.T.,.F.,.F.)

    oReport:printDialog()

Return

Static Function fnImpres

    BeginSQL Alias cAliasSQL

        COLUMN D1_EMISSAO AS DATE

        SELECT SD1.*, F1_TIPO
        FROM %table:SD1% SD1
        JOIN %table:SF1% SF1 ON SF1.%notdel% 
                             AND F1_FILIAL  = D1_FILIAL 
                             AND F1_FORNECE = D1_FORNECE 
                             AND F1_LOJA    = D1_LOJA 
                             AND F1_DOC     = D1_DOC 
                             AND F1_SERIE   = D1_SERIE
        WHERE SD1.%notdel%
        AND D1_FILIAL   BETWEEN %exp:MV_PAR01% AND %exp:MV_PAR02%
        AND D1_EMISSAO  BETWEEN %exp:MV_PAR03% AND %exp:MV_PAR04%
        AND D1_CF       BETWEEN %exp:MV_PAR05% AND %exp:MV_PAR06%
        AND D1_SERIE    BETWEEN %exp:MV_PAR07% AND %exp:MV_PAR08%
        AND D1_DOC      BETWEEN %exp:MV_PAR09% AND %exp:MV_PAR10%
        AND D1_FORNECE  BETWEEN %exp:MV_PAR11% AND %exp:MV_PAR13%
        AND D1_LOJA     BETWEEN %exp:MV_PAR12% AND %exp:MV_PAR14%
        ORDER BY D1_FILIAL, D1_EMISSAO, D1_FORNECE, D1_LOJA, D1_DOC, D1_SERIE

    EndSQL

    cSQL := getLastQuery()[2]
    (cAliasSQL)->(dbGoTop())

    oSection:print()

Return

/*/{Protheus.doc} fnRptPer
    Processa o grupo de perguntas
    @type  Static Function
    @author user
/*/
Static Function fnRptPer

    cPerg := padr(cPerg,10)

    IF .not. SX1->(dbSetOrder(1),dbSeek(cPerg+'01'))
        SX1->(reclock(alias(),.T.))
            SX1->X1_GRUPO	 	:= cPerg
            SX1->X1_ORDEM 		:= '01'
            SX1->X1_PERGUNT		:= 'Filial de?'
            SX1->X1_PERSPA		:= 'Filial de?'
            SX1->X1_PERENG		:= 'Filial de?'
            SX1->X1_VARIAVL		:= 'MV_CH1'
            SX1->X1_TIPO		:= 'C'
            SX1->X1_TAMANHO		:= tamSX3('D1_FILIAL')[1]
            SX1->X1_DECIMAL		:= 0
            SX1->X1_PRESEL		:= 0
            SX1->X1_GSC			:= 'G'
            SX1->X1_VALID		:= ''
            SX1->X1_VAR01		:= 'MV_PAR01'
            SX1->X1_F3			:= 'SM0'
        SX1->(msunlock())
    EndIF

    IF .not. SX1->(dbSetOrder(1),dbSeek(cPerg+'02'))
        SX1->(reclock(alias(),.T.))
            SX1->X1_GRUPO	 	:= cPerg
            SX1->X1_ORDEM 		:= '02'
            SX1->X1_PERGUNT		:= 'Filial ate?'
            SX1->X1_PERSPA		:= 'Filial ate?'
            SX1->X1_PERENG		:= 'Filial ate?'
            SX1->X1_VARIAVL		:= 'MV_CH2'
            SX1->X1_TIPO		:= 'C'
            SX1->X1_TAMANHO		:= tamSX3('D1_FILIAL')[1]
            SX1->X1_DECIMAL		:= 0
            SX1->X1_PRESEL		:= 0
            SX1->X1_GSC			:= 'G'
            SX1->X1_VALID		:= ''
            SX1->X1_VAR01		:= 'MV_PAR02'
            SX1->X1_F3			:= 'SM0'
        SX1->(msunlock())
    EndIF    

    IF .not. SX1->(dbSetOrder(1),dbSeek(cPerg+'03'))
        SX1->(reclock(alias(),.T.))
            SX1->X1_GRUPO	 	:= cPerg
            SX1->X1_ORDEM 		:= '03'
            SX1->X1_PERGUNT		:= 'Emissao de?'
            SX1->X1_PERSPA		:= 'Emissao de?'
            SX1->X1_PERENG		:= 'Emissao de?'
            SX1->X1_VARIAVL		:= 'MV_CH3'
            SX1->X1_TIPO		:= 'D'
            SX1->X1_TAMANHO		:= tamSX3('D1_EMISSAO')[1]
            SX1->X1_DECIMAL		:= 0
            SX1->X1_PRESEL		:= 0
            SX1->X1_GSC			:= 'G'
            SX1->X1_VALID		:= ''
            SX1->X1_VAR01		:= 'MV_PAR03'
            SX1->X1_F3			:= ''
        SX1->(msunlock())
    EndIF

    IF .not. SX1->(dbSetOrder(1),dbSeek(cPerg+'04'))
        SX1->(reclock(alias(),.T.))
            SX1->X1_GRUPO	 	:= cPerg
            SX1->X1_ORDEM 		:= '04'
            SX1->X1_PERGUNT		:= 'Emissao ate?'
            SX1->X1_PERSPA		:= 'Emissao ate?'
            SX1->X1_PERENG		:= 'Emissao ate?'
            SX1->X1_VARIAVL		:= 'MV_CH4'
            SX1->X1_TIPO		:= 'D'
            SX1->X1_TAMANHO		:= tamSX3('D1_EMISSAO')[1]
            SX1->X1_DECIMAL		:= 0
            SX1->X1_PRESEL		:= 0
            SX1->X1_GSC			:= 'G'
            SX1->X1_VALID		:= ''
            SX1->X1_VAR01		:= 'MV_PAR04'
            SX1->X1_F3			:= ''
        SX1->(msunlock())
    EndIF     

    IF .not. SX1->(dbSetOrder(1),dbSeek(cPerg+'05'))
        SX1->(reclock(alias(),.T.))
            SX1->X1_GRUPO	 	:= cPerg
            SX1->X1_ORDEM 		:= '05'
            SX1->X1_PERGUNT		:= 'CFOP de?'
            SX1->X1_PERSPA		:= 'CFOP de?'
            SX1->X1_PERENG		:= 'CFOP de?'
            SX1->X1_VARIAVL		:= 'MV_CH5'
            SX1->X1_TIPO		:= 'C'
            SX1->X1_TAMANHO		:= tamSX3('D1_CF')[1]
            SX1->X1_DECIMAL		:= 0
            SX1->X1_PRESEL		:= 0
            SX1->X1_GSC			:= 'G'
            SX1->X1_VALID		:= ''
            SX1->X1_VAR01		:= 'MV_PAR05'
            SX1->X1_F3			:= '13'
        SX1->(msunlock())
    EndIF

    IF .not. SX1->(dbSetOrder(1),dbSeek(cPerg+'06'))
        SX1->(reclock(alias(),.T.))
            SX1->X1_GRUPO	 	:= cPerg
            SX1->X1_ORDEM 		:= '06'
            SX1->X1_PERGUNT		:= 'CFOP ate?'
            SX1->X1_PERSPA		:= 'CFOP ate?'
            SX1->X1_PERENG		:= 'CFOP ate?'
            SX1->X1_VARIAVL		:= 'MV_CH6'
            SX1->X1_TIPO		:= 'C'
            SX1->X1_TAMANHO		:= tamSX3('D1_CF')[1]
            SX1->X1_DECIMAL		:= 0
            SX1->X1_PRESEL		:= 0
            SX1->X1_GSC			:= 'G'
            SX1->X1_VALID		:= ''
            SX1->X1_VAR01		:= 'MV_PAR06'
            SX1->X1_F3			:= '13'
        SX1->(msunlock())
    EndIF   

    IF .not. SX1->(dbSetOrder(1),dbSeek(cPerg+'07'))
        SX1->(reclock(alias(),.T.))
            SX1->X1_GRUPO	 	:= cPerg
            SX1->X1_ORDEM 		:= '07'
            SX1->X1_PERGUNT		:= 'Serie de?'
            SX1->X1_PERSPA		:= 'Serie de?'
            SX1->X1_PERENG		:= 'Serie de?'
            SX1->X1_VARIAVL		:= 'MV_CH7'
            SX1->X1_TIPO		:= 'C'
            SX1->X1_TAMANHO		:= tamSX3('D1_SERIE')[1]
            SX1->X1_DECIMAL		:= 0
            SX1->X1_PRESEL		:= 0
            SX1->X1_GSC			:= 'G'
            SX1->X1_VALID		:= ''
            SX1->X1_VAR01		:= 'MV_PAR07'
            SX1->X1_F3			:= ''
        SX1->(msunlock())
    EndIF

    IF .not. SX1->(dbSetOrder(1),dbSeek(cPerg+'08'))
        SX1->(reclock(alias(),.T.))
            SX1->X1_GRUPO	 	:= cPerg
            SX1->X1_ORDEM 		:= '08'
            SX1->X1_PERGUNT		:= 'Serie ate?'
            SX1->X1_PERSPA		:= 'Serie ate?'
            SX1->X1_PERENG		:= 'Serie ate?'
            SX1->X1_VARIAVL		:= 'MV_CH8'
            SX1->X1_TIPO		:= 'C'
            SX1->X1_TAMANHO		:= tamSX3('D1_SERIE')[1]
            SX1->X1_DECIMAL		:= 0
            SX1->X1_PRESEL		:= 0
            SX1->X1_GSC			:= 'G'
            SX1->X1_VALID		:= ''
            SX1->X1_VAR01		:= 'MV_PAR08'
            SX1->X1_F3			:= ''
        SX1->(msunlock())
    EndIF 

    IF .not. SX1->(dbSetOrder(1),dbSeek(cPerg+'09'))
        SX1->(reclock(alias(),.T.))
            SX1->X1_GRUPO	 	:= cPerg
            SX1->X1_ORDEM 		:= '09'
            SX1->X1_PERGUNT		:= 'Nota de?'
            SX1->X1_PERSPA		:= 'Nota de?'
            SX1->X1_PERENG		:= 'Nota de?'
            SX1->X1_VARIAVL		:= 'MV_CH9'
            SX1->X1_TIPO		:= 'C'
            SX1->X1_TAMANHO		:= tamSX3('D1_DOC')[1]
            SX1->X1_DECIMAL		:= 0
            SX1->X1_PRESEL		:= 0
            SX1->X1_GSC			:= 'G'
            SX1->X1_VALID		:= ''
            SX1->X1_VAR01		:= 'MV_PAR09'
            SX1->X1_F3			:= ''
        SX1->(msunlock())
    EndIF

    IF .not. SX1->(dbSetOrder(1),dbSeek(cPerg+'10'))
        SX1->(reclock(alias(),.T.))
            SX1->X1_GRUPO	 	:= cPerg
            SX1->X1_ORDEM 		:= '10'
            SX1->X1_PERGUNT		:= 'Nota ate?'
            SX1->X1_PERSPA		:= 'Nota ate?'
            SX1->X1_PERENG		:= 'Nota ate?'
            SX1->X1_VARIAVL		:= 'MV_CHA'
            SX1->X1_TIPO		:= 'C'
            SX1->X1_TAMANHO		:= tamSX3('D1_DOC')[1]
            SX1->X1_DECIMAL		:= 0
            SX1->X1_PRESEL		:= 0
            SX1->X1_GSC			:= 'G'
            SX1->X1_VALID		:= ''
            SX1->X1_VAR01		:= 'MV_PAR10'
            SX1->X1_F3			:= ''
        SX1->(msunlock())
    EndIF   

    IF .not. SX1->(dbSetOrder(1),dbSeek(cPerg+'11'))
        SX1->(reclock(alias(),.T.))
            SX1->X1_GRUPO	 	:= cPerg
            SX1->X1_ORDEM 		:= '11'
            SX1->X1_PERGUNT		:= 'Fornecedor de?'
            SX1->X1_PERSPA		:= 'Fornecedor de?'
            SX1->X1_PERENG		:= 'Fornecedor de?'
            SX1->X1_VARIAVL		:= 'MV_CHB'
            SX1->X1_TIPO		:= 'C'
            SX1->X1_TAMANHO		:= tamSX3('D1_FORNECE')[1]
            SX1->X1_DECIMAL		:= 0
            SX1->X1_PRESEL		:= 0
            SX1->X1_GSC			:= 'G'
            SX1->X1_VALID		:= ''
            SX1->X1_VAR01		:= 'MV_PAR11'
            SX1->X1_F3			:= 'SA2'
        SX1->(msunlock())
    EndIF

    IF .not. SX1->(dbSetOrder(1),dbSeek(cPerg+'12'))
        SX1->(reclock(alias(),.T.))
            SX1->X1_GRUPO	 	:= cPerg
            SX1->X1_ORDEM 		:= '12'
            SX1->X1_PERGUNT		:= 'Loja de?'
            SX1->X1_PERSPA		:= 'Loja de?'
            SX1->X1_PERENG		:= 'Loja de?'
            SX1->X1_VARIAVL		:= 'MV_CHC'
            SX1->X1_TIPO		:= 'C'
            SX1->X1_TAMANHO		:= tamSX3('D1_LOJA')[1]
            SX1->X1_DECIMAL		:= 0
            SX1->X1_PRESEL		:= 0
            SX1->X1_GSC			:= 'G'
            SX1->X1_VALID		:= ''
            SX1->X1_VAR01		:= 'MV_PAR12'
            SX1->X1_F3			:= ''
        SX1->(msunlock())
    EndIF  

    IF .not. SX1->(dbSetOrder(1),dbSeek(cPerg+'13'))
        SX1->(reclock(alias(),.T.))
            SX1->X1_GRUPO	 	:= cPerg
            SX1->X1_ORDEM 		:= '13'
            SX1->X1_PERGUNT		:= 'Fornecedor ate?'
            SX1->X1_PERSPA		:= 'Fornecedor ate?'
            SX1->X1_PERENG		:= 'Fornecedor ate?'
            SX1->X1_VARIAVL		:= 'MV_CHD'
            SX1->X1_TIPO		:= 'C'
            SX1->X1_TAMANHO		:= tamSX3('D1_FORNECE')[1]
            SX1->X1_DECIMAL		:= 0
            SX1->X1_PRESEL		:= 0
            SX1->X1_GSC			:= 'G'
            SX1->X1_VALID		:= ''
            SX1->X1_VAR01		:= 'MV_PAR13'
            SX1->X1_F3			:= 'SA2'
        SX1->(msunlock())
    EndIF

    IF .not. SX1->(dbSetOrder(1),dbSeek(cPerg+'14'))
        SX1->(reclock(alias(),.T.))
            SX1->X1_GRUPO	 	:= cPerg
            SX1->X1_ORDEM 		:= '14'
            SX1->X1_PERGUNT		:= 'Loja ate?'
            SX1->X1_PERSPA		:= 'Loja ate?'
            SX1->X1_PERENG		:= 'Loja ate?'
            SX1->X1_VARIAVL		:= 'MV_CHE'
            SX1->X1_TIPO		:= 'C'
            SX1->X1_TAMANHO		:= tamSX3('D1_LOJA')[1]
            SX1->X1_DECIMAL		:= 0
            SX1->X1_PRESEL		:= 0
            SX1->X1_GSC			:= 'G'
            SX1->X1_VALID		:= ''
            SX1->X1_VAR01		:= 'MV_PAR14'
            SX1->X1_F3			:= ''
        SX1->(msunlock())
    EndIF                    
    
Return 

/*/{Protheus.doc} U_RPT001A
    Retorna nome e UF de acordo com o tipo de nota fiscal
    @type  Function
    /*/
Function U_RPT001A

    Local cNome := ''

    IF type('__cRptUF') <> 'C'
        Public __cRptUF := ''
    Else
        __cRptUF := ''
    EndIF     

    IF (cAliasSQL)->F1_TIPO $ 'D/B'

        SA1->(dbSetOrder(1),dbSeek(xFilial(alias(),(cAliasSQL)->D1_FILIAL)+(cAliasSQL)->(D1_FORNECE+D1_LOJA)))
        cNome    := alltrim(SA1->A1_NOME)
        __cRptUF := SA1->A1_EST

    Else

        SA2->(dbSetOrder(1),dbSeek(xFilial(alias(),(cAliasSQL)->D1_FILIAL)+(cAliasSQL)->(D1_FORNECE+D1_LOJA)))
        cNome    := alltrim(SA2->A2_NOME)
        __cRptUF := SA2->A2_EST    

    EndIF       
    
Return cNome

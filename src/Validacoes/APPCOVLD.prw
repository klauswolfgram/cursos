#include 'totvs.ch'

/*/{Protheus.doc} User Function APPCOVLD
    (long_description)
    @type  Function
    @author user
    @since 31/05/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/

User Function APPCOVLD(nOpca,aParans)

    Default nOpca   := 0
    Default aParans := {}

    IF nOpca = 0
        return .T.
    ElseIF nOpca = 1
        return valid_oc()    
    EndIF

Return .T.

Static Function valid_upd()

    

Return

Static Function valid_oc() 

    Local cAliasSQL := ''
    Local cContaOr  := AKD->AKD_CO
    Local cPeriodo  := dtos(SC7->C7_EMISSAO)
    Local cOperac   := SC7->C7_YOPERAC
    Local cContaC   := SC7->C7_CONTA
    Local cIniPer   := ''
    Local cFimPer   := ''
    Local nValorPL  := 0
    Local nVlrDif   := 0
    Local xDados    := Nil
    Local aCtasLib  := {'610070101','610070102','610070103','610070201','610070202'} 

    //-- Contas liberadas conforme tabela informada pelo usuario
    IF aScan(aCtasLib,alltrim(cContaOr)) > 0
        return .T.
    EndIF         

    SB1->(dbsetorder(1),dbseek(xfilial('SB1')+SC7->C7_PRODUTO))

    IF SB1->(fieldpos('B1_YOPERAC')) > 0
        cOperac     := iif(empty(cOperac),SB1->B1_YOPERAC,cOperac)
    EndIF    
    
    IF SBM->(dbsetorder(1),dbseek(xfilial('SBM')+SB1->B1_GRUPO))
        cContaC     := SBM->BM_YCTADES
        IF SBM->(fieldpos('BM_YOPERAC')) > 0
            cOperac := iif(empty(cOperac),SBM->BM_YOPERAC,cOperac)
        EndIF    
    EndIF

    //-- Valida se a conta possui saldo em outra conta (Tabela SZ1)
    IF tccanopen(retsqlname('SZ1'))

        cAliasSQL   := getnextalias()

        BeginSQL Alias cAliasSQL
            SELECT * FROM %Table:SZ1% SZ1
            WHERE SZ1.%notdel%
            AND Z1_FILIAL = %Exp:xFilial('SZ1')%
            AND Z1_CO     = %Exp:cContaOr%
            AND Z1_ITCC   = %Exp:cContaC%
            AND Z1_ITOPER = %Exp:cOperac%
            AND ROWNUM    = 1
        EndSQL

        (cAliasSQL)->(dbeval({|| cContaC := Z1_CC, cOperac := Z1_ITOPER}),dbclosearea())

    EndIF

    //-- Verifica se trata-se de conta da usina com saldo na gerencia geral.
    IF substr(cContaOr,1,3) == '611'

        cAliasSQL := getnextalias()

        BeginSQL Alias cAliasSQL
            SELECT 
            AK1_INIPER,AK1_FIMPER,AK2.* 
            FROM %Table:AK1% AK1 
            JOIN %Table:AK2% AK2 ON AK2.D_E_L_E_T_= ' ' 
                            AND AK2_FILIAL = AK1_FILIAL 
                            AND AK2_ORCAME = AK1_CODIGO 
                            AND AK2_VERSAO = AK1_VERSAO 
            WHERE  AK1.D_E_L_E_T_= ' ' 
            AND AK1_FILIAL =  %Exp:xFilial('AK1',SC7->C7_FILIAL)%
            AND AK2_DATAI  >= %Exp:cPeriodo%
            AND AK2_DATAF  <= %Exp:cPeriodo%
            AND AK2_CO     =  %Exp:cContaOr%  
            AND AK2_OPER   =  %Exp:cOperac%   
            ORDER BY AK2_PERIOD ASC   
                    
        EndSQL

        While .not. (cAliasSQL)->(eof())
            
            IF (cAliasSQL)->AK2_VALOR = 0.01
                cContaOr := getnewpar('ZZ_CTUSINA','611010101')
                Exit
            EndIF

            (cAliasSQL)->(dbskip())

        Enddo

        (cAliasSQL)->(dbclosearea())

        memowrite('C:\temp\APPCOVLD_PL.SQL',getlastquery()[2])

    EndIF

    IF type('lPlanilha') <> 'L'
        Public lPlanilha := .F.
    EndIF

    lPlanilha       := .F.    

    IF type('__aDadosBlq') = 'A'
        xDados := aClone(__aDadosBlq)
    EndIF    

    //-- recupera as planilhas orcamentarias do periodo
    cAliasSQL       := getnextalias()

    BeginSQL Alias cAliasSQL
        SELECT 
        AK1_INIPER,AK1_FIMPER,AK2.* 
        FROM %Table:AK1% AK1 
        JOIN %Table:AK2% AK2 ON AK2.D_E_L_E_T_= ' ' 
                        AND AK2_FILIAL = AK1_FILIAL 
                        AND AK2_ORCAME = AK1_CODIGO 
                        AND AK2_VERSAO = AK1_VERSAO 
        WHERE  AK1.D_E_L_E_T_= ' ' 
        AND AK1_FILIAL =  %Exp:xFilial('AK1',SC7->C7_FILIAL)%
        AND AK1_INIPER <= %Exp:cPeriodo%
        AND AK1_FIMPER >= %Exp:cPeriodo%
        AND AK2_CO     =  %Exp:cContaOr% 
        AND AK2_OPER   =  %Exp:cOperac%
        AND NOT SUBSTR(AK2_PERIOD,1,6) > %Exp:substr(cPeriodo,1,6)%    
        ORDER BY AK2_PERIOD ASC           
    EndSQL

    memowrite('C:\temp\APPCOVLD_PL.SQL',getlastquery()[2])

    (cAliasSQL)->(dbeval({|| nValorPL += AK2_VALOR, cIniPer := AK1_INIPER, cFimPer := AK1_FIMPER, lPlanilha := .T.}),dbclosearea()) 

    IF .not. lPlanilha
        
        cMsg := oemtoansi('Os dados orçamentários informados não estão previstos em planilha orçamentária no módulo PCO')
        cMsg += CRLF + oemtoansi('CONTA ORÇAMENTÁRIA: ' + cContaOr  )
        cMsg += CRLF + oemtoansi('OPERAÇÃO: '           + cOperac   )
    //  cMsg += CRLF + oemtoansi('CONTA CONTÁBIL: '     + cContaC   )
        
        msgstop(cMsg,oemtoansi('SALDO INSUFICIENTE'))
        
        return .F.

    EndIF    

    nVlrOC  := StaticCall(APPCOMNT,VLROC,1,2) 
    nVlrDif := nVlrOC - nValorPL 

    IF nValorPL = 0
        
        cMsg := oemtoansi('SALDO DA CONTA ORÇAMENTARIA: '   ) +;
                transform(nValorPL,"@E 999,999,999.99"      ) +;
                CRLF                                          +;
                oemtoansi('ACUMULADO CONTA ORÇAMENTARIA: '  ) +;
                transform(nVlrOC,"@E 999,999,999.99"        ) +;
                CRLF                                          +;
                oemtoansi('DIFERENÇA:'                      ) +;
                transform(nVlrDif,"@E 999,999,999.99"       )     

        msgstop(cMsg,oemtoansi('SALDO INSUFICIENTE'))
         
        return .F.

    EndIF      

    IF nVlrOC > nValorPL    
        
        cMsg := oemtoansi('SALDO DA CONTA ORÇAMENTARIA: '   ) +;
                transform(nValorPL,"@E 999,999,999.99"      ) +;
                CRLF                                          +;
                oemtoansi('ACUMULADO CONTA ORÇAMENTARIA: '  ) +;
                transform(nVlrOC,"@E 999,999,999.99"        ) +;
                CRLF                                          +;
                oemtoansi('DIFERENÇA:'                      ) +;
                transform(nVlrDif,"@E 999,999,999.99"       )

        msgstop(cMsg,oemtoansi('SALDO INSUFICIENTE'))
        
        return .F.

    EndIF    
    
Return .T.

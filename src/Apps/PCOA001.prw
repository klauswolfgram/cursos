#include 'protheus.ch'
#include 'parmtype.ch'

/*/
{Protheus.doc} PCOA001
Programa para exportacao de dados do cadastro de naturezas financeiras para o cadastro de operações orçamentárias do PCO.
Faz uma varredura no cadastro de naturezas financeiras e verifica se existe equivalente no cadastro de contas orcamentarias.
@author Klaus Wolfgram
@since 12/12/2019
@version 1.0
@type user function
/*/
user function pcoa001(lMenu)

    Default lMenu := .F.

    FwMsgRun(,{|| pcoa001()},'Atualizacao das operações orcamentárias','Aguarde...')
    
    IF lMenu
        msginfo('OK')
    EndIF    
	
return

//-- Executa a rotina de atualizacao
static function pcoa001

    Local cAliasSQL := GetNextAlias()
    
    BeginSQL Alias cAliasSQL
        SELECT ED_FILIAL, ED_CODIGO, ED_DESCRIC, ED_PAI, ED_TIPO
        FROM %Table:SED% SED
        LEFT OUTER JOIN %Table:AKF% AKF ON AKF_FILIAL = %Exp:xFilial('AKF')% AND AKF_CODIGO = ED_CODIGO AND AKF.%notdel%
        WHERE SED.%notdel%
        AND AKF_CODIGO IS NULL
        ORDER BY ED_FILIAL,ED_CODIGO
    EndSQL
    
    memowrite('C:\temp\pcoa001.sql',getlastquery()[2])
    
    While .not. (cAliasSQL)->(EOF())

        AKF->(dbsetorder(1),reclock('AKF',.T.),AKF_FILIAL := xFilial('AKF'),AKF_CODIGO := (cAliasSQL)->ED_CODIGO,AKF_DESCRI := (cAliasSQL)->ED_DESCRIC,msunlock())            
        (cAliasSQL)->(dbSkip())
        
    Enddo   

return

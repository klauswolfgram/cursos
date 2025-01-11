#include 'totvs.ch'

/*/{Protheus.doc} User Function MT120GRV
    (long_description)
    @type  Function
    @author user
    @since 21/07/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/

User Function MT120GRV

    Local aParans := paramixb

    //-- Verifica se trata-se de operacao de inclusao e libera a gravacao
    IF aParans[2]
        return .T.
    EndIF

    //-- Verifica se o pedido ainda nao foi liberado para compras e continua a gravacao ou nao
    IF .not. SCR->(dbsetorder(1),dbseek(xfilial('SCR')+'PC'+aParans[1]))
        IF .not. SCR->(dbsetorder(1),dbseek(xfilial('SCR')+'IP'+aParans[1]))
            return .T.
        EndIF    
    EndiF     

    IF empty(SCR->CR_DATALIB)
        return .T.
    EndIF

    //-- Verifica se o mes atual eh superior ao mes da liberacao e impede a gravacao
    IF month(ddatabase) > month(SCR->CR_DATALIB)
        msgstop(oemtoansi('Esse pedido foi liberado fora do mês atual, por isso não poderá ser alterado/excluído. Caso necessário, utilize a eliminação de resíduos e gere um novo pedido.') + CRLF + oemtoansi('Data da liberação: ') + dtoc(SCR->CR_DATALIB),oemtoansi('Atenção'))
        return .F.
    EndIF      
    
Return .T.

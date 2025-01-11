#include 'totvs.ch'

/*/{Protheus.doc} SIGAPCP
    Ponto de entrada acionado pelo modulo SIGAPCP.
    @type  User Function 
    @author Klaus Wolfgram
    @since 21/01/2023
    @version 1.0

    @history 21/01/2023, Klaus Wolfgram, Inclusao do arquivo de codigo fonte.
    /*/
User Function SIGAPCP()
    
    //-- Gera registros na tabela SM2 - Cadastro de moedas
    U_YT0001()
    
Return 

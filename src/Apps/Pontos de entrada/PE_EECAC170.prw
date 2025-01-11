#include 'totvs.ch'

/*/{Protheus.doc} User Function EECAC170
    (long_description)
    @type  Function
    @author user
    @since 23/08/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function EECAC170

    Local cOpcao := paramixb

    IF valtype(cOpcao) == 'A'
        cOpcao := paramixb[1]
    EndIF

    IF upper(alltrim(cOpcao)) == 'FINAL_GRAVA'

        IF .not. msgyesno(oemtoansi('Confirma a atualização dos dados do navio nos processos de embarque?'),oemtoansi('Confirmação'))
            return
        EndIF

        //AC170AtuNavio("NAVIO")

        lret := updemb()

    EndIF    
    
Return

Static Function updemb

    Local lret      := .T.

    Local dETA		:= M->EE6_ETAORI
    Local cETAHR	:= M->EE6_ETAHR
    Local dETB		:= M->EE6_ETB
    Local cETBHR	:= M->EE6_ETBHR
    Local dETD		:= M->EE6_ETSORI
    Local cETDHR	:= M->EE6_ETDHR
    Local dDraft	:= M->EE6_DLDRAF
    Local cDraftHr	:= M->EE6_DLDRHR
    Local dCarga	:= M->EE6_DEADLI
    Local cCargaHr	:= M->EE6_DLCAHR    

    IF EEC->(dbsetorder(16),dbseek(xfilial('EEC')+M->(EE6_COD+EE6_VIAGEM+EE6_ORIGEM)))

        While .not. EEC->(eof()) .and. EEC->(EEC_FILIAL+EEC_EMBARC+EEC_VIAGEM+EEC_ORIGEM) == xfilial('EEC')+M->(EE6_COD+EE6_VIAGEM+EE6_ORIGEM)

            EEC->(RecLock("EEC", .F.))
            EEC->EEC_ETA	 	:= dETA
            EEC->EEC_ETAHR 	    := cETAHR
            EEC->EEC_ETB 		:= dETB
            EEC->EEC_ETBHR 	    := cETBHR
            EEC->EEC_ETD	 	:= dETD
            EEC->EEC_ETDHR 	    := cETDHR
            EEC->EEC_DLDRAF 	:= dDraft
            EEC->EEC_DLDRHR 	:= cDraftHr
            EEC->EEC_DLCARGA 	:= dCarga
            EEC->EEC_DLCAHR 	:= cCargaHr
            EEC->(MsUnlock())

            EEC->(dbskip())

        Enddo

    EndIF

Return lret

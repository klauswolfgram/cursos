#include 'totvs.ch'

/*/{Protheus.doc} User Function PCOA002
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
    
User Function PCOA002

    Local dElimPed:= SC7->C7_YDTRES

    IF empty(dElimPed)
        dElimPed  := ddatabase
    EndIF   

    SC7->(reclock('SC7',.F.),C7_YDTRES := dElimPed,msunlock()) 
    
Return

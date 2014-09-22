Const CSIDL_COMMON_DESKTOPDIRECTORY = &H19 
Const CSIDL_DESKTOPDIRECTORY = &H10 
Set objShell = CreateObject("Shell.Application") 
Set objAllUsersDESKTOPFolder = objShell.NameSpace(CSIDL_COMMON_DESKTOPDIRECTORY) 
strAllUsersDESKTOPPath = objAllUsersDESKTOPFolder.Self.Path 
Set objFolder = objShell.Namespace(strAllUsersDESKTOPPath) 
Set objFolderItem = objFolder.ParseName("Total Commander PowerUser v59.lnk") 
Set colVerbs = objFolderItem.Verbs 
For Each objVerb in colVerbs 
    If Replace(objVerb.name, "&", "") = "Закрепить на панели задач" Then objVerb.DoIt 
Next
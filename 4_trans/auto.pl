use autolocale;
 
$ENV{"LANG"} = "C"; # locale is "C"
{
	    local $ENV{"LANG"} = "en_US";# locale is "en_US"
    }
    # locale is "C"
    #  
    #  no autolocale; # auto setlocale disabled
    #  $ENV{"LANG"} = "en_US"; # locale is "C"

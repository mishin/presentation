

function GetTranslation(key){ 
 uTrType = "";  
 isPrep = 0;
 $("#blurResult").show();
 $("#autoInfo").html('');
 $("#socialServices").hide();
 $("#AdvInResult").hide();
 $("#AdvInResult").removeAttr('style');
 $("#linkAT").show(); $("#linkATPic").show();
 $("#ttSourceText").hide();
 $("#btt").hide();
 visitLink=false; 
 $("#addTranslationText").unbind('keypress');
 closewAddTranslation();
 closeTranslationLinks();
 $("#divFullWordResult").hide();
 if (rtrim($("#SiteContent_sourceText").val())=="") {
	 $("#SiteContent_sourceText").val('');
	 $("#SiteContent_sourceText").focus();
	 return false;}    
 var arr = GetDir();
 var dir=arr[0]+'-'+arr[1];
 //var dir=GetDir();
 var text=rtrim($("#SiteContent_sourceText").val());
 text = encodeURIComponent(text).split("'").join("\\'");
 var templ=$("#template").val();
 
 $.ajax({
    type: "POST",
    contentType: "application/json; charset=utf-8",
    url: "/services/TranslationService.asmx/GetTranslateNew",
    data: "{ dirCode:'"+dir+"', template:'"+templ+"', text:'"+text+"', lang:'ru', limit:"+maxlen+",useAutoDetect:true, key:'"+key+"', ts:'"+TS+"',tid:'',IsMobile:false}", 
    dataType: "json",
    success: function(result){    
      var res=GetAjaxResult(result);
      SetValsAfterTr(res);
      trFdLnk = res.fdLink;
      curPtsDirCode = res.ptsDirCode;
      var curPtsDirCodeArr=curPtsDirCode.split('-')
      if (res.isWord && rtrim($('#SiteContent_sourceText').val())!='') {GetTopPhrases();}
//      $("#SiteContent_sourceText").css('min-height','');
//     $("#editResult_test").css('min-height','');
      //if (((GetDir()[0]== res.ptsDirCode[1])||(GetDir()[0]== 'a'))&&(GetDir()[1]== res.ptsDirCode[0])){
      if (((arr[0]== curPtsDirCodeArr[1])||(arr[0]== 'au'))&&(arr[1]== curPtsDirCodeArr[0])){
      //alert('автоматическая смена направления перевода');
      gaCustomVarsSet(res.ptsDirCode.split('-'));
      _gaq.push(['_trackEvent', 'Linguistic', 'Language', 'Auto']);}
      
      if (curVMode == 'vert'){$("#SiteContent_sourceText").attr('class','expand101-2400');
    jQuery("textarea[class*=expand]").TextAreaExpander();}
//       RefreshAdv();
       RefreshAdv_inRes();
//       RefreshAdvTop();

       reload_ban();
      
       customEvents.fire("onTranslate", '');
 
    },
    error: function (XMLHttpRequest, textStatus, errorThrown) { 
      GetErrMsg("К сожалению, сервис временно недоступен. Попробуйте повторить запрос позже."); trDirCode = "";
    }      
 });
}//GetTr

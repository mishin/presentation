//Дата загрузки
def loadingDT='2015-07-25';
//Корневая директория, где лежат скрипты и текущий скрипт в частности
def baseDir='c:/Workdir';
//Путь к программе запуска Datastage джобов
def dsJob='C:/IBM/InformationServer/Clients/Classic/dsjob.exe';
//Проект, в котором находится джоб
def dsProject='ProjectName';

//Запуск главной загрузки
//def jobName='Main_SEQ';
//def paramFile=setdoubleQuote("$baseDir/param/Main_SEQ_paramfile.txt");

def defBevahior=' -run -mode NORMAL -wait -jobstatus -warn 0 ';

//Загрузка отдельной таблицы
def filial='MSK'
def tableName='Clients'
def jobName="Load$_{tableName}_JOB";
def paramFile=setdoubleQuote("$baseDir/param/load_table_param.txt");

// пароль криптуем так
// set ds_encrypt="c:\IBM\InformationServer\ASBNode\bin\encrypt.bat" 
// %ds_encrypt% password

// Пример файла с паролем:

//user=Developer
//password={iisenc}sbGxCzyWf7G6uWd6/RZ6aQ==
//domain=dev-host:80
//server=dev-server

//Параметры авторизации
def authFile=setdoubleQuote("$baseDir/auth/dev_credential.txt");

//Кладем все необходимые параметры в хэш или мэп
def allParam = [
        dsJob  : dsJob,
        authFile: authFile,
        paramFile  : paramFile,
        dsProject  : dsProject,        
        jobName  : jobName,                
        loadingDT  : loadingDT,    
        defBevahior : defBevahior,                    
        filial : filial,                            
]

//Получаем информацию о джобе
//get_job_info(allParam)
//Запускаем джоб
//run_simple_job(allParam)
run_ds_job(allParam)
//Резетим джоб, если он завершился с ошибкой
//reset_job(allParam)

def get_job_info(param){
   def DScommand="$param.dsJob -authfile $param.authFile -jobinfo $param.dsProject $param.jobName"
   runCommand(DScommand); 
}

def reset_job(param){
   def defBevahior=' -run -mode RESET -wait -jobstatus ';
   def DScommand="$param.dsJob  -authfile $param.authFile $defBevahior $param.dsProject $param.jobName"
   runCommand(DScommand); 
}


def run_simple_job(param){
   //поведение(настройка джоба) по умолчанию.
   def DScommand="$param.dsJob  -authfile $param.authFile $param.defBevahior -paramfile $param.paramFile $param.dsProject $param.jobName"
   runCommand(DScommand); 
}

def run_ds_job(param){
   //поведение(настройка джоба) по умолчанию.
   def DScommand="$param.dsJob  -authfile $param.authFile $param.defBevahior -paramfile $param.paramFile -param LOADING_DT=$param.loadingDT -param PS_BIS_CONNECTIONS=$param.filial $param.dsProject $param.jobName"
   runCommand(DScommand); 
}


def setdoubleQuote(String myText) {
    quotes ='"';
    return quotes+myText+quotes;
}

//Выполнение команды операционной системы
def runCommand(strList) { 
  def proc = strList.execute()
  proc.in.eachLine { line -> println line }
  proc.out.close()
  proc.waitFor()

  print "[INFO] ( "
  if(strList instanceof List) {
    strList.each { print "${it} " }
  } else {
    print strList
  }
  println " )"

  if (proc.exitValue()) {
    println "gave the following error: "
    println "[ERROR] ${proc.getErrorStream()}"
  }
  assert !proc.exitValue()
}

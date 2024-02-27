# команды инициализации и запуска 1C внутри vnc
# при настройке линии сборки
vncserver -geometry 1600x900 :1
export DISPLAY=:1
export LANG='ru_RU.UTF-8'
export LANGUAGE='ru_RU:en'
export LC_ALL='ru_RU.UTF-8'
/opt/1cv8/x86_64/8.3.24.1342/1cv8 /UseHwLicenses- &

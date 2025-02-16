@setlocal
@ATH=C:\Program Files (x86)\Zonation5;%E:\E2O\zonation\test\SettingsFiles%

z5 -w --mode=CAZ2 --gui settings_T.z5 out_T
z5 -w --mode=CAZ2 --gui settings_FW.z5 out_FW
z5 -wh --mode=CAZ2 --gui settings_T_h.z5 out_T_h
z5 -wh --mode=CAZ2 --gui settings_FW_h.z5 out_FW_h
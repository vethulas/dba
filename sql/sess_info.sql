--#-----------------------------------------------------------------------------------
--# File Name    : sess_info.sql
--# Author       : https://gglybin.com
--# Description  : Shows information about database session based on given sid or pid. It can be modified for using other filters (program, username, etc).
--# Call Syntax  : @sess_info (session-sid)
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;
set verify off;
set linesize 120
set head off

select
'======================= General  =======================',
'SID, SERIAL# ...........................................: '||s.sid||','||s.serial#,
'OS PID .................................................: '||p.spid Server,
'USERNAME ...............................................: '||s.username,
'SCHEMA_NAME ............................................: '||s.schemaname,
'STATUS .................................................: '||s.status,
'EVENT ..................................................: '||s.event,
'======================== SQL ============================',
'CURRENT_SQL_ID .........................................: '||nvl(s.sql_id,'-'),
'CURRENT_SQL_TEXT .......................................: '||nvl((select sql_text from gv$sqlarea where sql_id in (select sql_id from gv$session where sid='&&1')),'-'),
'PREVIOUS_SQL_ID ........................................: '||nvl(s.prev_sql_id,'-'),
'PREVIOUS_SQL_TEXT ......................................: '||nvl((select sql_text from gv$sqlarea where sql_id in (select prev_sql_id from gv$session where sid='&&1')),'-'),
'LAST_CALL_ET [Sec] .....................................: '||s.last_call_et,
'LAST_CALL_ET [Min] .....................................: '||round(s.last_call_et/60),
'===================== Connection ========================',
'PROGRAM  ...............................................: '||s.program,
'MODULE .................................................: '||s.module,
'ACTION .................................................: '||s.action,
'TERMINAL ...............................................: '||s.terminal,
'CLIENT_MACHINE .........................................: '||s.machine,
'===================== Blockers? ========================',
'BLOCKING_STATUS ........................................: '||decode(s.final_blocking_session_status,'VALID','VALID = Blocking session exist'
                                                                                                    ,'NO HOLDER','NO HOLDER = No blockers'
                                                                                                    ,'NOT IN WAIT','NOT IN WAIT = This is not in a wait'
                                                                                                    ,'UNKNOWN','UNKNOWN = The blocking session is unknown'),  
'BLOCKING_INSTANCE ......................................: '||nvl(to_char(s.final_blocking_instance),'-'),
'BLOCKING_SID ...........................................: '||nvl(to_char(s.final_blocking_session),'-')
from  gv$session s,
      gv$process p
where p.addr=s.paddr 
and   s.sid='&&1'
--and p.spid='&&1';
Prompt
Prompt
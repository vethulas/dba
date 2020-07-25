--#-----------------------------------------------------------------------------------
--# File Name    : waits_info_hist.sql
--#
--# Description  : Shows information about sessions wait events in past (exclude idle events).
--#
--# Call Syntax  : @waits_info_hist (start-date) (end-date)
--#
--#                @waits_info_hist "11:00:00 19/06/2019" "11:15:00 19/06/2019"
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;
set verify off;

Prompt
Prompt ##
Prompt ## Events Count:
Prompt ##

col sample_time for a30
col wait_class  for a30
col event       for a70

select to_char(sample_time, 'HH24:MI:SS DD-MON-YYYY') SAMPLE_TIME
       ,wait_class
       ,event
       ,count(*) COUNT
from   dba_hist_active_sess_history
where  event is not null
and    event<>'SQL*Net message to client'
and    wait_class<>'Idle'
and    sample_time >= to_date ('&&1','HH24:MI:SS DD/MM/YYYY')
and    sample_time <= to_date ('&&2','HH24:MI:SS DD/MM/YYYY')
group  by sample_time, wait_class, event
order  by sample_time;

Prompt ##
Prompt ## Details:
Prompt ##

set pages 50

col sample_time   for a25
col "SID,SERIAL#" for a15
col session_type  for a15
col sql_id        for a15
col sql_opname    for a20
col "EVENT"       for a60
col wait_class    for a30

select to_char(sample_time, 'HH24:MI:SS DD-MON-YYYY') SAMPLE_TIME
       ,session_id || ',' || session_serial# "SID,SERIAL#"
       ,session_type
       ,sql_id
       ,sql_opname
       ,sql_plan_hash_value "PLAN_HASH"
       ,sql_full_plan_hash_value "FULL_PLAN_HASH"
       ,decode(event,'null event','ON CPU',null,'ON CPU',event)
       ,wait_class
from   dba_hist_active_sess_history
where  event<>'SQL*Net message to client'
and    wait_class<>'Idle'
and    sample_time >= to_date ('&&1','HH24:MI:SS DD/MM/YYYY')
and    sample_time <= to_date ('&&2','HH24:MI:SS DD/MM/YYYY')
group  by sample_time, wait_class, event, session_id, session_serial#, session_type, sql_id, sql_opname, sql_plan_hash_value, sql_full_plan_hash_value
order  by sample_time;

Prompt
Prompt Note: use "sess_info_past.sql" script to get some additional details about the session in past simple.
Prompt

--#-----------------------------------------------------------------------------------
--# File Name    : waits_info.sql
--# Author       : https://gglybin.com
--# Description  : Shows information about current sessions wait events (exclude idle events).
--# Call Syntax  : @waits_info
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;

select event
       ,count(*) as sess_count 
from   gv$session s
       ,gv$event_name e
where  s.event=e.name
and    e.wait_class<>'Idle'
and    e.name<>'SQL*Net message to client'
group  by event
order  by sess_count desc;

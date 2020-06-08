--#-----------------------------------------------------------------------------------
--# File Name    : lock_info.sql
--# Author       : https://gglybin.com
--# Description  : Shows information about current locks on objects in database.
--# Call Syntax  : @lock_info
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;

col LOCKED_MODE for a40

select substr(to_char(l.session_id)||','||to_char(s.serial#),1,15) SID_SERIAL
       ,substr(l.os_user_name||'/'||l.oracle_username,1,20) USERNAME
       ,substr(o.owner||'.'||o.object_name,1,35) OWNER_OBJECT
       ,decode(l.locked_mode, 1,'No Lock', 2,'Row Share', 3,'Row Exclusive', 4,'Share', 5,'Share Row Excl', 6,'Exclusive',null) LOCKED_MODE
       ,substr(s.status,1,10) SESS_STATUS 
from   v$locked_object l
       ,all_objects o
       ,v$session s
       ,v$process p 
where  l.object_id = o.object_id 
and    l.session_id = s.sid 
and    s.paddr = p.addr 
and    s.status != 'KILLED'; 

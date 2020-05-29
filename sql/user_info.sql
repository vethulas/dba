--#-----------------------------------------------------------------------------------
--# File Name    : user_info.sql
--# Author       : https://gglybin.com
--# Description  : Shows detailed information about user.
--# Call Syntax  : @user_info (user-name)
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000
set verify off;

Prompt
Prompt ##
Prompt ## General:
Prompt ##

col username              for a20
col account_status        for a20
col default_tablespace    for a20
col temporary_tablespace  for a20
col local_temp_tablespace for a22
col "CREATED"             for a18
col password_versions     for a18
col "LAST_PWD_CHANGE"     for a18
col "LAST_LOGIN"          for a18

select
       username
       ,user_id
       ,account_status
       ,default_tablespace
       ,temporary_tablespace
       ,local_temp_tablespace
       ,to_char(created, 'HH24:MI DD-MON-YY') as "CREATED"
       ,password_versions
       ,to_char(password_change_date, 'HH24:MI DD-MON-YY') as "LAST_PWD_CHANGE"
       ,to_char(last_login, 'HH24:MI DD-MON-YY') as "LAST_LOGIN"
from   dba_users
where  username='&&1';

Prompt ##
Prompt ## User profile:
Prompt ##

col username for a10
col profile  for a40

select 
      username
      ,profile 
from  dba_users 
where username='&&1';

Prompt ##
Prompt ## Roles assigned to user:
Prompt ##

col grantee         for a15
col granted_role    for a40
col admin_option    for a20
col delegate_option for a20
col default_role    for a20
col common          for a20
col inherited       for a20

select *
from   dba_role_privs
where  grantee='&&1'
order  by granted_role;

Prompt ##
Prompt ## Grants assigned directly to user:
Prompt ##

col privilege for a30

select *
from   dba_sys_privs
where  grantee='&&1'
order  by privilege;

Prompt ##
Prompt ## Table grants assigned directly to user:
Prompt ##

col owner      for a15
col table_name for a20
col grantor    for a15
col privilege  for a20
col grantable  for a20
col hierarchy  for a20
col common     for a20
col type       for a20
col inherited  for a20

select *
from   dba_tab_privs
where  grantee='&&1'
order  by table_name desc;

Prompt ##
Prompt ## Current count of sessions:
Prompt ##

col username for a20
col machine  for a40

break on report
compute sum label 'Total' of COUNT on report

select 
       username
       ,machine
       ,status
       , count(*) as "COUNT"
from   v$session
where  username='&&1'
group  by username, machine, status
order  by 3 desc;

/*
Prompt ##
Prompt ## Session details:
Prompt ##

alter session set nls_date_format = 'DD-MON-YYYY HH24:MI:SS';

col logon_time  for a20
col username    for a20
col schemaname  for a20
col status      for a10
col "OSPROCESS" for a10
col osuser      for a15
col machine     for a20
col program     for a30
col module      for a20
col event       for a50

select
       s.logon_time
       ,s.username
       ,s.schemaname
       ,s.status
       ,s.sid
       ,s.serial#
       ,p.spid as "OSPROCESS"
       ,s.osuser
       ,s.machine
       ,s.program
       ,s.module
       ,s.event
from   v$session s
       ,v$process p
where  s.username='&&1'
and    s.paddr=p.addr
order  by logon_time desc, status desc;
*/

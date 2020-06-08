--#-----------------------------------------------------------------------------------
--# File Name    : tbs_temp_info.sql
--# Author       : https://gglybin.com
--# Description  : Shows information about temporary tablespace usage.
--# Call Syntax  : @tbs_temp_info
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;

Prompt
Prompt ##
Prompt ## Info:
Prompt ##

col tablespace_name   for a40
col status            for a15
col contents          for a10
col bigfile           for a10
col extent_management for a20

select tablespace_name
       ,status
       ,block_size
       ,contents
       ,bigfile
       ,extent_management
from   dba_tablespaces
where  contents='TEMPORARY'
order  by tablespace_name;

Prompt ##
Prompt ## Usage:
Prompt ##

select a.tablespace_name tablespace
       ,d.mb_total
       ,sum(a.used_blocks * d.block_size) / 1024 / 1024 mb_used
       ,d.mb_total - sum(a.used_blocks * d.block_size) / 1024 / 1024 mb_free
       ,(100 - round(100 * ((d.mb_total - sum(a.used_blocks * d.block_size) / 1024 / 1024) / d.mb_total))) "USAGE_%" 
from   v$sort_segment a,
       (
        select b.name
               ,c.block_size
               ,sum(c.bytes) / 1024 / 1024 mb_total
        from   v$tablespace b
               ,v$tempfile  c
        where  b.ts#= c.ts#
        group  by b.name, c.block_size
       ) d
where  a.tablespace_name=d.name
group  by a.tablespace_name, d.mb_total;

Prompt ##
Prompt ## Top 10 Sessions used TEMP:
Prompt ##

col tablespace   for a20
col temp_size_mb for 99,999,999
col sid_serial   for a20
col username     for a20
col program      for a50

select res.*
from 
    (select b.tablespace
           ,round(((b.blocks*p.value)/1024/1024),2) temp_size_mb
           ,a.inst_id
           ,a.sid||','||a.serial# sid_serial
           ,nvl(a.username, '(oracle)') username
           ,a.program
           ,a.status
           ,a.sql_id
    from   gv$session a,
           gv$sort_usage b,
           gv$parameter p
    where  p.name='db_block_size'
    and    a.saddr=b.session_addr
    and    a.inst_id=b.inst_id
    and    a.inst_id=p.inst_id
    order  by temp_size_mb desc
    ) res
where rownum <= 10;

Prompt ##
Prompt ## Top 10 Sessions used TEMP:
Prompt ##

col osuser for a15
col module for a30

select res.*
from
    (select s.sid || ',' || s.serial# sid_serial
           ,s.username
           ,s.osuser
           ,p.spid
           ,s.module
           ,p.program
           ,sum(t.blocks) * tbs.block_size / 1024 / 1024 mb_used
           ,t.tablespace
           ,count(*) statements
    from   v$sort_usage t
           ,v$session s
           ,dba_tablespaces tbs
           ,v$process p
    where  t.session_addr = s.saddr
    and    s.paddr=p.addr
    and    t.tablespace=tbs.tablespace_name
    group  by s.sid, s.serial#, s.username, s.osuser, p.spid, s.module, p.program, tbs.block_size, t.tablespace
    order  by mb_used desc
    ) res
where  rownum <= 10;

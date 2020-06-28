--#-----------------------------------------------------------------------------------
--# File Name    : tbs_usage_info.sql
--#
--# Description  : Shows usage information about all data tablespaces.
--#
--# Call Syntax  : @tbs_usage_info
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;

Prompt
Prompt ##
Prompt ## Usage:
Prompt ##

column "Tablespace" format a40
column "Used MB"    format 99,999,999
column "Free MB"    format 99,999,999
column "Total MB"   format 99,999,999

select p1.*
from  (select fs.tablespace_name                                     "Tablespace"
              ,(df.totalspace - fs.freespace)                        "Used MB"
              ,fs.freespace                                          "Free MB"
              ,df.totalspace                                         "Total MB"
              ,round(100 * (fs.freespace / df.totalspace))           "Free %"
              ,(100 - round(100 * (fs.freespace / df.totalspace)))   "Usage %"
       from
              (select tablespace_name
                      ,round(sum(bytes) / 1048576) TotalSpace
               from   dba_data_files
               group  by tablespace_name
              ) df,
             (select  tablespace_name
                      ,round(sum(bytes) / 1048576) FreeSpace
              from    dba_free_space
              group   by tablespace_name
             ) fs
       where df.tablespace_name = fs.tablespace_name
      ) p1,
      dba_tablespaces p2
where p2.tablespace_name=p1."Tablespace"
and   p2.contents='PERMANENT'
order by p1."Total MB" desc, p1."Usage %" desc;

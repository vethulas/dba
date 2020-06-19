set lines 400 pages 1000;

Prompt
Prompt ##
Prompt ## Upgrade / Patch History
Prompt ##

col comments      for a60;
col action        for a12;
col version       for a35;
col namespace     for a10;
col bundle_series for a15;
col action_time   for a35;

select * 
from   registry$history 
order  by ACTION_TIME;

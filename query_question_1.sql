  with active_repos as (
select o.org_id
     , c.repo_id
     , c.startedanalysis
     , c.endedanalysis
     , date_trunc('isoweek', c.startedanalysis) as week_start
     , extract(week from c.startedanalysis) as week_number
     , extract(epoch from (c.endedanalysis - c.startedanalysis)) / 60 as analysis_duration
  from commits c
 inner join organization o 
    on c.repo_id = o.repo_id
 where o.status = 'active'
   and c.status = true
   and c.startedanalysis >= current_date - interval '90 days'
)

select org_id
     , week_start  
     , week_number  
     , round(avg(analysis_duration), 2) as weekly_avg_duration_minutes
  from active_repos
 group by org_id 
     , week_start
     , week_number
 order by org_id 
     , week_number
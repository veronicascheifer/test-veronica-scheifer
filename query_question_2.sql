  with shift_pairs as (
select e.employee_name
     , l1.tap_timestamp as clock_in
     , lead(l1.tap_timestamp) over (
            partition by l1.card_id
            order by l1.tap_timestamp asc
       ) as clock_out
     , date_trunc('isoweek', l1.tap_timestamp) as week_start
     , extract(week from l1.tap_timestamp) as week_number
  from log l1
 inner join employee e 
    on l1.card_id = e.card_id
)

select employee_name
     , week_start
     , week_number
     , round(sum(extract(epoch from (clock_out - clock_in)) / 60)) as shift_duration_minutes
  from shift_pairs
 group by employee_name
     , week_start
     , week_number
 order by employee_name
     , week_number
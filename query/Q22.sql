select
cntrycode,
count(*) as numcust,
sum(c_acctbal) as totacctbal
from
(
select
substr(c_phone from 1 for 2) as cntrycode,
c_acctbal
from
CUSTOMER
where
substr(c_phone from 1 for 2) in
('26', '13', '21', '28', '11', '12', '19')
and c_acctbal > (
select
avg(c_acctbal)
from
CUSTOMER
where
c_acctbal > 0.00
and substr(c_phone from 1 for 2) in
('26', '13', '21', '28', '11', '12', '19')
)
and not exists (
select
*
from
ORDERS
where
o_custkey = c_custkey
)
) as custsale
group by
cntrycode
order by
cntrycode;


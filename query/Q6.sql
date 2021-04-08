select
	sum(l_extendedprice * l_discount) as revenue
from
	LINEITEM
where
	l_shipdate >= '1994-01-01'
	and l_shipdate < date_add( '1994-01-01' , interval '1' year)
	and l_discount between 0.03 - 0.01 and 0.03 + 0.01
	and l_quantity < 24;

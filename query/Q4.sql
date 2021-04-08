select
	o_orderpriority,
	count(*) as order_count
from
	ORDERS
where
	o_orderdate >=  '1996-08-01'
	and o_orderdate < date_add( '1996-08-01', interval '3' month)
	and exists (
		select
			*
		from
			LINEITEM
		where
			l_orderkey = o_orderkey
			and l_commitdate < l_receiptdate
	)
group by
	o_orderpriority
order by
	o_orderpriority;

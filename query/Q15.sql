with REVENUE (supplier_no, total_revenue) as (
	select
		l_suppkey,
		sum(l_extendedprice * (1 - l_discount))
	from
		LINEITEM
	where
		l_shipdate >= '1993-02-01'
		and l_shipdate < date_add('1993-02-01', interval '90' day)
	group by
		l_suppkey
)
select
	s_suppkey,
	s_name,
	s_address,
	s_phone,
	total_revenue
from
	SUPPLIER,
	REVENUE
where
	s_suppkey = supplier_no
	and total_revenue = (
		select
			max(total_revenue)
		from
			REVENUE
	)
order by
	s_suppkey;

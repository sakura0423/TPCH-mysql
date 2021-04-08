select
p_brand,
p_type,
p_size,
count(distinct ps_suppkey) as supplier_cnt
from
PARTSUPP,
PART
where
p_partkey = ps_partkey
and p_brand <> 'Brand#31'
and p_type not like 'PROMO BRUSHED%'
and p_size in (46, 26, 17, 35, 9, 25, 37, 7)
and ps_suppkey not in (
select
s_suppkey
from
SUPPLIER
where
s_comment like '%Customer%Complaints%'
)
group by
p_brand,
p_type,
p_size
order by
supplier_cnt desc,
p_brand,
p_type,
p_size;

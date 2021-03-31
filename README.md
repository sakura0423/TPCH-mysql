# TPCH-mysql


TPC-H是业界常用的一套基准，由TPC委员会制定发布，用于评测数据库的分析型查询能力。TPC-H查询包含8张数据表、22条复杂的SQL查询，大多数查询包含若干表Join、子查询和Group by聚合等。



## 参数说明

**SF**（Scale Factor）：数据库的比例因子。TPC-H标准规定，测试数据库的比例因子必须从下列固定值中选择：1，10,30,100,1000,3000,10000 (相当于1GB，10GB,30GB,100GB,1000GB,3000GB,10000GB)。
数据库的大小缺省定义为1（例如：SF＝1；近似于1GB）。

#### 

## 安装TPC-H

1. 需要去[官网](http://tpc.org/tpc_documents_current_versions/download_programs/tools-download-request5.asp?spm=a2c4g.11186623.2.11.79df2d24vfIXkS&bm_type=TPC-H&bm_vers=2.18.0&mode=CURRENT-ONLY)安装

2. 进入目录后，进入dbgen目录下

   ```shell
   # cd dbgen
   ```

3. 复制`makefile`文件

   ```shell
   # cp makefile.suite makefile
   ```

   

4. 修改makefile中的CC、DATABASE、MACHINE、WORKLOAD参数的定义。

   ```
     ################
     ## CHANGE NAME OF ANSI COMPILER HERE
     ################
     CC      = gcc
     # Current values for DATABASE are: INFORMIX, DB2, ORACLE,
     #                                  SQLSERVER, SYBASE, TDAT (Teradata)
     # Current values for MACHINE are:  ATT, DOS, HP, IBM, ICL, MVS,
     #                                  SGI, SUN, U2200, VMS, LINUX, WIN32
     # Current values for WORKLOAD are:  TPCH
     DATABASE= MYSQL
     MACHINE = LINUX
     WORKLOAD = TPCH
   ```

5. 修改`tpcd.h`，添加如下的宏定义：

   ```c++
   #ifdef MYSQL
   #define GEN_QUERY_PLAN ""
   #define START_TRAN "START TRANSACTION"
   #define END_TRAN "COMMIT"
   #define SET_OUTPUT ""
   #define SET_ROWCOUNT "limit %d;\n"
   #define SET_DBASE "use %s;\n"
   #endif
   ```

6. 编译

   ```shell
   make
   ```

   编译结束后目录下会生成两个可执行文件：

   - `dbgen`：数据生成工具。在使用InfiniDB官方测试脚本进行测试时，需要用该工具生成tpch相关表数据。
   - `qgen`：SQL生成工具。生成初始化测试查询，由于不同的seed生成的查询不同，为了结果的可重复性，请使用附件提供的22个查询。

7. 生成tpch的测试数据集，`-s` 即前面提到的参数SF：

   ```shell
   # ./dbgen -s 100 
   ```

8. 生成查询，为了测试结果可重复，一般直接使用一样的 query

   - 将`qgen`与`dists.dss`复制到queries目录

     ```shell
     # cp qgen queries
     # cp dists.dss queries
     ```

   - 使用以下脚本生成查询

     ```shell
     #!/usr/bin/bash
     for i in {1..22}
     do  
       ./qgen -d $i -s 100 > db"$i".sql
     done
     ```







## 测试方法

1. 创建数据库

   ```sh
   > create database tpch;
   ```

2. 创建表

   ```mysql
   > use tpch;
   > source ./dss.ddl;
   ```

3. 加载数据，将一下内容保存在`load.ddl`

   ```mysql
   load data local INFILE 'customer.tbl' INTO TABLE CUSTOMER FIELDS TERMINATED BY '|';
   load data local INFILE 'region.tbl' INTO TABLE REGION FIELDS TERMINATED BY '|';
   load data local INFILE 'nation.tbl' INTO TABLE NATION FIELDS TERMINATED BY '|';
   load data local INFILE 'supplier.tbl' INTO TABLE SUPPLIER FIELDS TERMINATED BY '|';
   load data local INFILE 'part.tbl' INTO TABLE PART FIELDS TERMINATED BY '|';
   load data local INFILE 'partsupp.tbl' INTO TABLE PARTSUPP FIELDS TERMINATED BY '|';
   load data local INFILE 'orders.tbl' INTO TABLE ORDERS FIELDS TERMINATED BY '|';
   load data local INFILE 'lineitem.tbl' INTO TABLE LINEITEM FIELDS TERMINATED BY '|';
   ```

   为了导入数据，首先要设置`local_infile`，接着执行脚本：

   ```mysql
   > SET GLOBAL local_infile=1;
   > source ./load.ddl;
   ```

4. 将`dss.ri`文件改为：

   ```mysql
   use tpch;
   -- ALTER TABLE REGION DROP PRIMARY KEY;
   -- ALTER TABLE NATION DROP PRIMARY KEY;
   -- ALTER TABLE PART DROP PRIMARY KEY;
   -- ALTER TABLE SUPPLIER DROP PRIMARY KEY;
   -- ALTER TABLE PARTSUPP DROP PRIMARY KEY;
   -- ALTER TABLE ORDERS DROP PRIMARY KEY;
   -- ALTER TABLE LINEITEM DROP PRIMARY KEY;
   -- ALTER TABLE CUSTOMER DROP PRIMARY KEY;
   -- For table REGION
   ALTER TABLE REGION
   ADD PRIMARY KEY (R_REGIONKEY);
   -- For table NATION
   ALTER TABLE NATION
   ADD PRIMARY KEY (N_NATIONKEY);
   ALTER TABLE NATION
   ADD FOREIGN KEY NATION_FK1 (N_REGIONKEY) references REGION(R_REGIONKEY);
   COMMIT WORK;
   -- For table PART
   ALTER TABLE PART
   ADD PRIMARY KEY (P_PARTKEY);
   COMMIT WORK;
   -- For table SUPPLIER
   ALTER TABLE SUPPLIER
   ADD PRIMARY KEY (S_SUPPKEY);
   ALTER TABLE SUPPLIER
   ADD FOREIGN KEY SUPPLIER_FK1 (S_NATIONKEY) references NATION(N_NATIONKEY);
   COMMIT WORK;
   -- For table PARTSUPP
   ALTER TABLE PARTSUPP
   ADD PRIMARY KEY (PS_PARTKEY,PS_SUPPKEY);
   COMMIT WORK;
   -- For table CUSTOMER
   ALTER TABLE CUSTOMER
   ADD PRIMARY KEY (C_CUSTKEY);
   ALTER TABLE CUSTOMER
   ADD FOREIGN KEY CUSTOMER_FK1 (C_NATIONKEY) references NATION(N_NATIONKEY);
   COMMIT WORK;
   -- For table LINEITEM
   ALTER TABLE LINEITEM
   ADD PRIMARY KEY (L_ORDERKEY,L_LINENUMBER);
   COMMIT WORK;
   -- For table ORDERS
   ALTER TABLE ORDERS
   ADD PRIMARY KEY (O_ORDERKEY);
   COMMIT WORK;
   -- For table PARTSUPP
   ALTER TABLE PARTSUPP
   ADD FOREIGN KEY PARTSUPP_FK1 (PS_SUPPKEY) references SUPPLIER(S_SUPPKEY);
   COMMIT WORK;
   ALTER TABLE PARTSUPP
   ADD FOREIGN KEY PARTSUPP_FK2 (PS_PARTKEY) references PART(P_PARTKEY);
   COMMIT WORK;
   -- For table ORDERS
   ALTER TABLE ORDERS
   ADD FOREIGN KEY ORDERS_FK1 (O_CUSTKEY) references CUSTOMER(C_CUSTKEY);
   COMMIT WORK;
   -- For table LINEITEM
   ALTER TABLE LINEITEM
   ADD FOREIGN KEY LINEITEM_FK1 (L_ORDERKEY)  references ORDERS(O_ORDERKEY);
   COMMIT WORK;
   ALTER TABLE LINEITEM
   ADD FOREIGN KEY LINEITEM_FK2 (L_PARTKEY,L_SUPPKEY) references 
           PARTSUPP(PS_PARTKEY,PS_SUPPKEY);
   COMMIT WORK;
   ```

   ​	

   然后执行脚本来创建主外键：

   ```mysql
   source ./dss.ri
   ```



5. 创建索引（可省略）

   ```mysql
   create index i_s_nationkey on SUPPLIER  (s_nationkey);
   create index i_ps_partkey on PARTSUPP (ps_partkey);
   create index i_ps_suppkey on PARTSUPP (ps_suppkey);
   create index i_c_nationkey on CUSTOMER (c_nationkey);
   create index i_o_custkey on ORDERS (o_custkey);
   create index i_o_orderdate on ORDERS (o_orderdate);
   create index i_l_orderkey on LINEITEM (l_orderkey);
   create index i_l_partkey on LINEITEM (l_partkey);
   create index i_l_suppkey on LINEITEM(l_suppkey);
   create index i_l_partkey_suppkey on LINEITEM (l_partkey, l_suppkey);
   create index i_l_shipdate on LINEITEM (l_shipdate);
   create index i_l_commitdate on LINEITEM (l_commitdate);
   create index i_l_receiptdate on LINEITEM (l_receiptdate);
   create index i_n_regionkey on NATION (n_regionkey);
   analyze table SUPPLIER;
   analyze table PART;
   analyze table PARTSUPP;
   analyze table CUSTOMER;
   analyze table ORDERS;
   analyze table LINEITEM;
   analyze table NATION;
   analyze table REGION;
   ```

   
## 测试

查看query的[含义](

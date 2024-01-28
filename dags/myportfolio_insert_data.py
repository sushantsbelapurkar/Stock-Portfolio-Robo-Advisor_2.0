import datetime

from airflow import DAG
from airflow.providers.mysql.operators.mysql import MySqlOperator

args = {
    "owner": "Sushant",
    "depends_on_past": False,
    "retries": 2,
    "retry_delay": datetime.timedelta(minutes=5),
    "start_date": datetime.datetime(2020, 11, 30),
}

dag = DAG(
    dag_id="myportfolio_insert_data",
    default_args=args,
    max_active_runs=1,
    schedule_interval="0 12 5 * *",
    params={"execution_sla": None},
    template_searchpath="/Users/sudip/airflow/sqls/",
    catchup=False,
)

task_pro_sequential_clean_master = MySqlOperator(
    task_id="pro_sequential_clean_master",
    # timeout=86400,
    dag=dag,
    sql="mysql_portfolio/db_insert_data/1_clean_master_data.sql",
    mysql_conn_id='mysql_localhost'
)

task_pro_sequential_run_nse1 = MySqlOperator(
    task_id="pro_sequential_run_nse1",
    # timeout=86400,
    dag=dag,
    sql="mysql_portfolio/db_insert_data/14_pro_sequential_run_nse1.sql",
    mysql_conn_id='mysql_localhost'
)

task_pro_sequential_run_nse2 = MySqlOperator(
    task_id="pro_sequential_run_nse2",
    # timeout=86400,
    dag=dag,
    sql="mysql_portfolio/db_insert_data/15_pro_sequential_run_nse2.sql",
    mysql_conn_id='mysql_localhost'
)

task_pro_sequential_run_nyse1 = MySqlOperator(
    task_id="pro_sequential_run_nyse1",
    # timeout=86400,
    dag=dag,
    sql="mysql_portfolio/db_insert_data/16_pro_sequential_run_nyse1.sql",
    mysql_conn_id='mysql_localhost'
)

task_pro_sequential_run_nyse2 = MySqlOperator(
    task_id="pro_sequential_run_nyse2",
    # timeout=86400,
    dag=dag,
    sql="mysql_portfolio/db_insert_data/17_pro_sequential_run_nyse2.sql",
    mysql_conn_id='mysql_localhost'
)

task_pro_sequential_run_nasdaq1 = MySqlOperator(
    task_id="pro_sequential_run_nasdaq1",
    # timeout=86400,
    dag=dag,
    sql="mysql_portfolio/db_insert_data/18_pro_sequential_run_nasdaq1.sql",
    mysql_conn_id='mysql_localhost'
)

task_pro_sequential_run_nasdaq2 = MySqlOperator(
    task_id="pro_sequential_run_nasdaq2",
    # timeout=86400,
    dag=dag,
    sql="mysql_portfolio/db_insert_data/19_pro_sequential_run_nasdaq2.sql",
    mysql_conn_id='mysql_localhost'
)

task_pro_sequential_run_bse1 = MySqlOperator(
    task_id="pro_sequential_run_bse1",
    # timeout=86400,
    dag=dag,
    sql="mysql_portfolio/db_insert_data/20_pro_sequential_run_bse1.sql",
    mysql_conn_id='mysql_localhost'
)

task_pro_sequential_run_bse2 = MySqlOperator(
    task_id="pro_sequential_run_bse2",
    # timeout=86400,
    dag=dag,
    sql="mysql_portfolio/db_insert_data/21_pro_sequential_run_bse2.sql",
    mysql_conn_id='mysql_localhost'
)

task_pro_sequential_clean_master >> task_pro_sequential_run_nse1 >> task_pro_sequential_run_nse2 >> task_pro_sequential_run_nyse1 >> task_pro_sequential_run_nyse2 >> task_pro_sequential_run_nasdaq1 >> task_pro_sequential_run_nasdaq2 >> task_pro_sequential_run_bse1 >> task_pro_sequential_run_bse2

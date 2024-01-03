import datetime

from airflow import DAG
from airflow.providers.postgres.operators.postgres import PostgresOperator
from airflow.providers.mysql.operators.mysql import MySqlOperator
from airflow.utils.dates import days_ago

args = {
    "owner": "Sushant",
    "depends_on_past": False,
    "retries": 2,
    "retry_delay": datetime.timedelta(minutes=5),
    "start_date": datetime.datetime(2020, 11, 30),
}

dag = DAG(
    dag_id="myportfolio",
    default_args=args,
    max_active_runs=1,
    schedule_interval="0 12 5 * *",
    params={"execution_sla": None},
    template_searchpath="/Users/sudip/airflow/sqls/",
    catchup=False,
)

task_pro_eps_info = MySqlOperator(
    task_id="pro_eps_info",
    dag=dag,
    sql="master_setup/01_pro_eps_info.sql",
    mysql_conn_id='mysql_conn_id'
)

task_pro_carg_info = MySqlOperator(
    task_id="pro_carg_info",
    dag=dag,
    sql="master_setup/02_pro_carg_info.sql",
    mysql_conn_id='mysql_conn_id'
)

task_pro_carg_info = MySqlOperator(
    task_id="pro_carg_info",
    dag=dag,
    sql="master_setup/02_pro_carg_info.sql",
    mysql_conn_id='mysql_conn_id'
)

task_pro_eps_info >> task_pro_carg_info

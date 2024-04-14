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
    dag_id="myportfolio_initial_setup",
    default_args=args,
    max_active_runs=1,
    schedule_interval="0 12 5 * *",
    params={"execution_sla": None},
    template_searchpath="/Users/sudip/airflow/sqls/",
    catchup=False,
)

task_ddl_create = MySqlOperator(
    task_id="ddl_create",
    dag=dag,
    sql="mysql_portfolio/db_create_structure/1_ddl_creation.sql",
    mysql_conn_id='mysql_localhost'
)


task_pro_eps_info = MySqlOperator(
    task_id="pro_eps_info",
    dag=dag,
    sql="mysql_portfolio/db_create_structure/01_pro_eps_info.sql",
    mysql_conn_id='mysql_localhost'
)

task_pro_carg_info = MySqlOperator(
    task_id="pro_carg_info",
    dag=dag,
    sql="mysql_portfolio/db_create_structure/02_pro_carg_info.sql",
    mysql_conn_id='mysql_localhost'
)

task_pro_golden_death_cross = MySqlOperator(
    task_id="pro_golden_death_cross",
    dag=dag,
    sql="mysql_portfolio/db_create_structure/03_pro_golden_death_cross.sql",
    mysql_conn_id='mysql_localhost'
)

task_pro_pe_pb_analysis = MySqlOperator(
    task_id="pro_pe_pb_analysis",
    dag=dag,
    sql="mysql_portfolio/db_create_structure/04_pro_pe_pb_analysis.sql",
    mysql_conn_id='mysql_localhost'

)

task_pro_price_to_cashflow_analysis = MySqlOperator(
    task_id="pro_price_to_cashflow_analysis",
    dag=dag,
    sql="mysql_portfolio/db_create_structure/05_pro_price_to_cashflow_analysis.sql",
    mysql_conn_id='mysql_localhost'
)

task_pro_decision_view = MySqlOperator(
    task_id="pro_decision_view",
    dag=dag,
    sql="mysql_portfolio/db_create_structure/03_06_pro_decision_view.sql",
    mysql_conn_id='mysql_localhost'
)

task_pro_fundamental_analysis = MySqlOperator(
    task_id="pro_fundamental_analysis",
    dag=dag,
    sql="mysql_portfolio/db_create_structure/07_pro_fundamental_analysis.sql",
    mysql_conn_id='mysql_localhost'
)

pro_value_analysis = MySqlOperator(
    task_id="pro_value_analysis",
    dag=dag,
    sql="mysql_portfolio/db_create_structure/08_pro_value_analysis.sql",
    mysql_conn_id='mysql_localhost'
)

task_pro_growth_analysis = MySqlOperator(
    task_id="pro_growth_analysis",
    dag=dag,
    sql="mysql_portfolio/db_create_structure/09_pro_growth_analysis.sql",
    mysql_conn_id='mysql_localhost'
)

task_pro_capm_wacc_calc = MySqlOperator(
    task_id="pro_capm_wacc_calc",
    dag=dag,
    sql="mysql_portfolio/db_create_structure/03_10_pro_capm_wacc_calc.sql",
    mysql_conn_id='mysql_localhost'

)

task_pro_DCF_valuation = MySqlOperator(
    task_id="pro_DCF_valuation",
    dag=dag,
    sql="mysql_portfolio/db_create_structure/11_pro_DCF_valuation.sql",
    mysql_conn_id='mysql_localhost'
)

task_pro_company_analysis = MySqlOperator(
    task_id="pro_company_analysis",
    dag=dag,
    sql="mysql_portfolio/db_create_structure/12_pro_company_analysis.sql",
    mysql_conn_id='mysql_localhost'
)

task_pro_clean_master = MySqlOperator(
    task_id="pro_clean_master",
    # timeout=86400,
    dag=dag,
    sql="mysql_portfolio/db_cleanup/02_clean_master_data.sql",
    mysql_conn_id='mysql_localhost'
)

task_ddl_create  >> task_pro_eps_info >> task_pro_carg_info >> task_pro_golden_death_cross >> task_pro_pe_pb_analysis >> task_pro_price_to_cashflow_analysis >> task_pro_decision_view >> task_pro_fundamental_analysis >> pro_value_analysis >> task_pro_growth_analysis >> task_pro_capm_wacc_calc >> task_pro_DCF_valuation >> task_pro_company_analysis >> task_pro_clean_master

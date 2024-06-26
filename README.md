Advanced Stock-Portfolio-Robo-Advisor project, enhancing the  [initial version](https://github.com/sushantsbelapurkar/Stock-Portfolio-Robo-Advisor) with a focus on in-depth analysis of 10 years of listed companies financial results and 30 years of stock exchange data. Design and implemented automatic rebalancing stock portfolios based on three strategies: Fundamental Analysis, Value Analysis, and Growth Analysis, guided by Benjamin Graham's and Peter Lynch's investment principles.
The project employs advanced Data Modeling and data warehousing concepts for data storage and analysis. It fetches results for each company for the last ten years and historical prices for 30 years from an API, constructing a robust data warehouse. This enables analysis from various perspectives using different algorithmic logics, implemented with advanced SQL and Python.
<br> Details of the projects can be found in the [project white paper](https://github.com/sushantsbelapurkar/Stock-Portfolio-Robo-Advisor/blob/master/1_Portfolio_Robo_Advisor_White_paper.pdf).

Furthermore, the portfolio is now managed automatically using Airflow DAG, where stopred procedures are executed sequentially to run the entire analysis.

Over the last 5 years, this portfolio delivered annual returns consistently surpassing the S&P 500 index.

Please note that the provided code is a snippet intended to protect sensitive information and proprietary logic, as the website is still in progress. However, it demonstrates the foundational components of the overall backend.

Below images shows the feature importance and model accuracy derived from machine learning models:

![Feature_importance](https://github.com/sushantsbelapurkar/Stock-Portfolio-Robo-Advisor_2.0/assets/59714916/1f3989c2-7236-4e10-9d12-22cd1ff465b8)
![DNN_Post_PCA](https://github.com/sushantsbelapurkar/Stock-Portfolio-Robo-Advisor_2.0/assets/59714916/43a33cc5-cc7c-4a62-8a5d-e3fc3e1741cf)

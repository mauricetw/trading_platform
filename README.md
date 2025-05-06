# trading_platform
113專題

# trading_database
1. 安裝 MySQL:用 XAMPP 套裝（有圖形界面）
2. 安裝虛擬環境（建議）

   在cmd中執行
	-	 	python -m venv venv  #安裝虛擬機
	-	  venv\Scripts\activate  #啟動虛擬機
 
4. 安裝 FastAPI、Uvicorn、MySQL、provider 相關套件：
	 -	 	pip install fastapi uvicorn sqlalchemy mysql-connector-python python-multipart passlib[bcrypt]

   fastapi：主框架
   
   uvicorn：執行 FastAPI 的伺服器
   
   sqlalchemy：ORM 資料表映射工具
   
   mysql-connector-python：連接 MySQL 用
   
   python-multipart：定義資料結構（FastAPI 自帶）
   
   passlib[bcrypt]：密碼加密（註冊/登入用）

   provider： 狀態管理，版本 ^6.0.5

5. 建立基本專案結構：

	> /trading_backend/
 	> 
	> │
 	> 
	> ├── main.py               # FastAPI 主入口
 	> 
	> ├── requirements.txt      # 專案用到的所有Python套件
 	> 
	> │
 	> 
	> ├── database/
 	> 
	> │   ├── __init__.py        # SQLAlchemy資料庫連線設定
 	> 
	> │
 	> 
	> ├── models/
 	> 
	> │   ├── __init__.py
 	> 
	> │   ├── user.py            # User資料表模型
 	> 
	> │   ├── product.py         # Product資料表模型
 	> 
	> │   ├── order.py           # Order資料表模型
 	> 
	> │
 	> 
	> ├── schemas/
 	> 
	> │   ├── __init__.py
 	> 
	> │   ├── user_schema.py     # User資料表用到的資料結構
 	> 
	> │   ├── product_schema.py  # Product資料表用到的資料結構
 	> 
	> │   ├── order_schema.py    # Order資料表用到的資料結構
 	> 
	> │
 	> 
	> ├── routers/
 	> 
	> │   ├── __init__.py
 	> 
	> │   ├── auth.py            # 登入/註冊/忘記密碼/重設密碼功能
 	> 
	> │   ├── product.py         # 商品相關API
 	> 
	> │   ├── order.py           # 訂單相關API
 	> 
	> │
 	> 
	> ├── utils/
 	> 
	> │   ├── __init__.py
 	> 
	> │   ├── hashing.py         # 密碼加密驗證
 	> 
	> │   ├── token.py           # 重設密碼的token生成與驗證
 	> 
	> │
 	> 
	> ├── mail_config.py         # 發送email相關設定
 	> 
	> │
 	> 
	> └── .env                   # 環境變數設定（如資料庫帳密）


 - schema:用來描述資料庫內中的表格結構、欄位格式以及記載每個表格中的關聯。當你日後要寫入的資料不符合 Schema 的規範時，那就會出現錯誤。
 - routers:各種操作所需的API
 - models:資料表中的資料模型
 - database:連接MySQL資料庫
 - utils:加密/生成token
 
	>
	> trading_platform/
 	>
	> ├── lib/
 	> 
	> │   ├── models/
 	>
 	> │   │   └── ... 其他分類資料夾
 	>
 	> │   ├── providers/
 	>
 	> │   │   └── ... 其他分類資料夾
 	>
	> │   ├── screens/
 	>
	> │   │   └── ... 介面
 	>
	> │   ├── main.dart   

## 使用XAMPP建立MySQL資料庫
1. 啟動 MySQL
   
	打開 XAMPP 控制面板（Windows）或應用程式（macOS）

	啟動 Apache 模組，因為 phpMyAdmin 是透過 Apache 提供的

	點擊 Start MySQL 模組

	如果成功，會看到「Running」綠色標示
3. 使用 phpMyAdmin 建立資料庫
   
	XAMPP 安裝後內建一個圖形化介面叫 phpMyAdmin，很方便建立資料庫
4. Python MySQL 資料庫連線設定

	 MySQL 資訊會是：
	 -	   DATABASE_URL = "mysql+mysqlconnector://root@localhost/tradingDB"
5. 執行後端伺服器：

   在專案資料夾cmd中執行
   -	 uvicorn main:app --reload

	 打開瀏覽器 → 打開 http://127.0.0.1:8000/docs

	 就會看到自動產生的 REST API 測試介面(Swagger UI)

	 **REST API**：REST API（Representational State Transfer Application Programming Interface）是一種透過 HTTP 提供資料與操作的「通用標準」。
   
	 - GET：取得
	 - POST：新增
	 - DELET：刪除

	 **Swagger UI**：Swagger UI 是一個自動生成的 API 文件與測試工具，可以幫你：

	 - 查看所有 API 路徑、請求格式、回傳格式
  	 - 在瀏覽器直接測試 API（像 Postman 一樣）
  	 - 幫前端工程師快速理解 API 怎麼使用

      **REST API 與 Swagger UI 的關係**
	 - REST API：是你實作的 API 接口本體 / 給 Flutter App 或其他前端使用 / 沒有圖形介面
 	 - Swagger UI：是 FastAPI 幫你「自動產生」的文件與測試工具 / 給開發者閱讀、測試用的畫面 / 有好看的介面，可以互動呼叫 API
     

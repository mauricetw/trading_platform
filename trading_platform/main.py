from fastapi import FastAPI
from database import Base, engine
from routers import users, products, orders

app = FastAPI()

# 初始化資料表
Base.metadata.create_all(bind=engine)

# 掛載 API 路由
app.include_router(users.router)
app.include_router(products.router)
app.include_router(orders.router)

# 測試用
@app.get("/")
def home():
    return {"message": "後端運作中"}

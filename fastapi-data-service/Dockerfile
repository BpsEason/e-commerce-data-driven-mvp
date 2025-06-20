# e-commerce-data-driven-mvp/fastapi-data-service/Dockerfile
# FastAPI 應用程式的 Dockerfile

# 使用 Python 3.10 的 slim-buster 映像作為基礎映像，體積較小
FROM python:3.10-slim-buster

# 設定工作目錄
WORKDIR /app

# 將 requirements.txt 文件複製到工作目錄
COPY requirements.txt .

# 安裝所有 Python 依賴
# --no-cache-dir: 不緩存 pip 下載的包，減少映像大小
RUN pip install --no-cache-dir -r requirements.txt

# 將應用程式代碼複製到容器的工作目錄
COPY . .

# 暴露 FastAPI 應用程式將監聽的端口
EXPOSE 8000

# 啟動 FastAPI 應用程式的命令
# uvicorn app.main:app: 運行 app/main.py 文件中的 app 實例
# --host 0.0.0.0: 讓應用程式監聽所有網絡接口
# --port 8000: 應用程式監聽的端口
# --reload: 開啟熱重載 (僅在開發環境中建議使用)
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]

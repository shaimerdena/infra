import os
from contextlib import asynccontextmanager

import psycopg
from psycopg_pool import ConnectionPool, PoolTimeout
from fastapi import FastAPI
from fastapi.responses import JSONResponse


@asynccontextmanager
async def lifespan(app: FastAPI):
    pool = ConnectionPool(
        conninfo=os.getenv(
            "DATABASE_URL",
            "postgresql://postgres:password@localhost:5432/mydb",
        ),
        min_size=1,
        max_size=5,
        timeout=2,
        open=False,
    )

    # Start the pool without waiting for PostgreSQL.
    pool.open(wait=False)
    app.state.db_pool = pool

    yield

    pool.close()


app = FastAPI(lifespan=lifespan)


@app.get("/")
def root():
    return {"message": "API is running"}


@app.get("/health")
def health():
    return {"status": "ok"}

@app.get("/health/live")
def liveness():
    return {"status": "alive"}

@app.get("/health/ready")
def readiness():
    pool = app.state.db_pool

    try:
        with pool.connection(timeout=5) as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT 1")
                result = cur.fetchone()

        return {"status": "ready", "database": "connected", "result": result[0]}

    except (PoolTimeout, psycopg.Error):
        return JSONResponse(
            status_code=503,
            content={"status": "not ready", "database": "unavailable"},
        )

@app.get("/db-time")
def get_db_time():
    pool = app.state.db_pool

    try:
        with pool.connection(timeout=5) as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT NOW()")
                result = cur.fetchone()

        return {"database_time": result[0]}

    except (PoolTimeout, psycopg.Error):
        return JSONResponse(
            status_code=503,
            content={"database": "unavailable"},
        )

@app.get("/pool-stats")
def pool_stats():
    return app.state.db_pool.get_stats()

@app.get("/db")
def check_database():
    pool = app.state.db_pool

    try:
        with pool.connection(timeout=2) as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT 1")
                result = cur.fetchone()

        return {"database": "connected", "result": result[0]}

    except (PoolTimeout, psycopg.Error):
        return JSONResponse(
            status_code=503,
            content={"database": "unavailable"},
        )

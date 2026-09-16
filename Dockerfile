# ==========================================
# ETAPA 1: Builder (Compilación de paquetes)
# ==========================================
FROM python:3.11-slim AS builder

WORKDIR /app

# Instalar dependencias del sistema necesarias para compilar paquetes
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Copiar el archivo de requerimientos e instalar las dependencias en una ruta específica o global
COPY requirements.txt .
# Instalamos en un directorio temporal /install para luego copiarlo limpiamente
RUN pip install --no-cache-dir -r requirements.txt

# ==========================================
# ETAPA 2: Final (Imagen liviana de ejecución)
# ==========================================
FROM python:3.11-slim AS final

WORKDIR /app

# Instalar librerías de tiempo de ejecución para PostgreSQL
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

# Crear usuario no raíz (non-root) primero para asignarle los permisos correctos
RUN useradd -m appuser

# Copiar las librerías instaladas desde la etapa builder al directorio del sistema de Python (/usr/local)
COPY --from=builder /usr/local /usr/local

# Copiar el código del proyecto
COPY . /app/

# Asegurar permisos correctos en el directorio de la aplicación para appuser
RUN chown -R appuser:appuser /app

# Variables de entorno
ENV PYTHONUNBUFFERED=1

# Cambiar al usuario no raíz
USER appuser

EXPOSE 8000

CMD ["gunicorn", "config.wsgi:application", "--bind", "0.0.0.0:8000"]
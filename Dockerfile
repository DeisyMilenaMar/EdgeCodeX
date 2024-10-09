# Etapa 1: Construcción
FROM python:3.10-buster AS builder

# Establece el directorio de trabajo
WORKDIR /app

# Instala las dependencias del sistema necesarias
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libc6-dev \
    libssl-dev \
    libffi-dev \
    build-essential \
    python3-dev \
    libpq-dev \
    libcurl4-openssl-dev \
    sqlite3 \
    && rm -rf /var/lib/apt/lists/*

# Copia solo los archivos necesarios para la instalación
COPY requirements.txt .

# Crea y activa un entorno virtual, actualiza pip e instala dependencias
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Etapa 2: Imagen final para producción
FROM python:3.10-slim-buster

# Reutiliza el mismo directorio de trabajo de la etapa anterior
WORKDIR /app

# Copia el entorno virtual de la etapa de construcción
COPY --from=builder /opt/venv /opt/venv

# Asegura que el entorno virtual se active en cada comando
ENV PATH="/opt/venv/bin:$PATH"

# Copia el código fuente del proyecto y el script entrypoint
COPY . .

# Asegúrate exitde que el archivo 'start' y 'entrypoint.sh' tienen permisos de ejecución
RUN chmod +x ./start ./entrypoint.sh

# Variables de entorno
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DJANGO_SETTINGS_MODULE=app.settings

# Crea un usuario no-root para ejecutar la aplicación
RUN useradd -m appuser
USER appuser

# Expone el puerto en el que correrá la aplicación Django
EXPOSE 8000

# Cambia el ENTRYPOINT para usar 'sh' explícitamente
ENTRYPOINT ["sh", "./entrypoint.sh"]

# Cambia el CMD para usar 'sh' explícitamente si es necesario
CMD ["sh", "./start"]

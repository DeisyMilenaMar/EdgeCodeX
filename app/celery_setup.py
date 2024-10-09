from __future__ import absolute_import, unicode_literals
import os
from celery import Celery
from django.conf import settings
import logging

# Verificación de DJANGO_SETTINGS_MODULE
if not os.environ.get('DJANGO_SETTINGS_MODULE', 'app.settings'):
    raise Exception('Please define the DJANGO_SETTINGS_MODULE environment variable')

# Crea la instancia de la aplicación Celery
app = Celery('app')

# Carga la configuración de Celery desde Django settings, usando el prefijo 'CELERY'
app.config_from_object('django.conf:settings', namespace='CELERY')

# Auto-descubre las tareas dentro de los archivos tasks.py en las apps registradas de Django
app.autodiscover_tasks(lambda: settings.INSTALLED_APPS)

# Configuración de logging
logger = logging.getLogger(__name__)

@app.task(bind=True)
def debug_task(self):
    logger.info(f'Request: {self.request!r}')

if __name__ == '__main__':
    app.start()
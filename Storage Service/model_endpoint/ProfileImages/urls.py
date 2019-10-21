from django.conf.urls import include, url
from django.views.generic import TemplateView
from django.views.decorators.csrf import csrf_exempt


from ProfileImages.views import UploadPhoto


urlpatterns = [
	url(r'^upload$', UploadPhoto.as_view(), name='upload_photo'),
]
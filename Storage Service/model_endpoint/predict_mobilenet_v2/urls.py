from django.conf.urls import include, url
from django.views.generic import TemplateView
from django.views.decorators.csrf import csrf_exempt


from predict_mobilenet_v2.views import TestModel


urlpatterns = [
	url(r'^test$', TestModel.as_view(), name='testmodel'),
]
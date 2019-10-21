from rest_framework import serializers
from django.db import transaction

from .models import UploadImage

class ImageSerializer(serializers.ModelSerializer):
    class Meta:
        model = UploadImage
        fields = ('name', 'image')
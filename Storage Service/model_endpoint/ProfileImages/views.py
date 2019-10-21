from django.shortcuts import render
from datetime import timedelta
from django.db.models import Q
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.decorators import action


import json
import logging

import requests
import stringcase
from django.contrib.auth import get_user_model
from django.contrib.auth.models import Group, User
from rest_framework import viewsets, status

import tensorflow as tf
import numpy as np
import argparse
import time

from .models import UploadImage
from .serializers import ImageSerializer

import os
import uuid

import socket    
hostname = socket.gethostname()    
IPAddr = socket.gethostbyname(hostname)


# Build paths inside the project like this: os.path.join(BASE_DIR, ...)
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Create your views here.

class UploadPhoto(APIView):
	queryset = UploadImage.objects.all()
	serializer_class = ImageSerializer
	def post(self, request, format=None):
		try:
			object_details = {}
			image_obj = UploadImage.objects.create(image=request.data['file'])
			client_ip = request.META['REMOTE_ADDR']
			image_path = os.path.join(BASE_DIR, 'media') + '/' + str(image_obj.image) 
			print ("-"*10,client_ip)

			# object_details = self.predict_image_class(image_path, LABEL_PATH, object_details)
			object_details['url'] = 'http://' + str(IPAddr) + ':8989/media/' + str(image_obj.image) 

			return Response(object_details , status.HTTP_200_OK, content_type='application/json')
		except Exception as e:
			print (e)
			return Response({'message': str(e)}, status.HTTP_400_BAD_REQUEST,
							content_type='application/json')

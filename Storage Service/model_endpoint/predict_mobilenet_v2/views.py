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

from subprocess import check_output
ips = check_output(['hostname', '--all-ip-addresses'])
IPAddr = ips.decode('utf-8')[:-2]


# Build paths inside the project like this: os.path.join(BASE_DIR, ...)
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Create your views here.
MODEL_PATH = "/mnt/project/MobileNet/MobileNet_V2/output_graph_oct_16.pb"

LABEL_PATH = "/mnt/project/MobileNet/MobileNet_V2/output_labels_oct_16.txt"



class TestModel(APIView):
	queryset = UploadImage.objects.all()
	serializer_class = ImageSerializer
	def post(self, request, format=None):
		try:
			object_details = {}
			image_obj = UploadImage.objects.create(image=request.data['file'])
			client_ip = request.META['REMOTE_ADDR']
			image_path = os.path.join(BASE_DIR, 'media') + '/' + str(image_obj.image) 
			print ("-"*10,client_ip)

			start = time.time()
			object_details = self.predict_image_class(image_path, LABEL_PATH, object_details, MODEL_PATH)
			object_details['url'] = 'http://' + str(IPAddr) + ':80/media/' + str(image_obj.image) 

			print ("Time to create session and classify-",(time.time()-start))

			return Response(object_details , status.HTTP_200_OK, content_type='application/json')
		except Exception as e:
			print (e)
			return Response({'message': str(e)}, status.HTTP_400_BAD_REQUEST,
							content_type='application/json')

	def get(self, request, format=None):
		try:
			object_details = {}
			object_details['message'] = "Get- works"

			return Response(object_details, status.HTTP_200_OK, content_type='application/json')
		except Exception as e:
			print(e)
			return Response({'message': 'Error in processing the request', 'status': 'Error'}, status.HTTP_400_BAD_REQUEST,
							content_type='application/json')

	def predict_image_class(self, image_path, lablelPath, object_details, modelPath):
		graph = tf.Graph()
		graph_def = tf.GraphDef()

		with open(modelPath, "rb") as f:
			graph_def.ParseFromString(f.read())
		with graph.as_default():
			tf.import_graph_def(graph_def)

		binary_image = self.read_tensor_from_image_file(image_path, input_height=224, input_width=224)

		input_name = "import/Placeholder"
		output_name = "import/final_result"
		input_operation = graph.get_operation_by_name(input_name)
		output_operation = graph.get_operation_by_name(output_name)
		with tf.Session(graph=graph) as sess:
			results = sess.run(output_operation.outputs[0], {
				input_operation.outputs[0]: binary_image
			})
		results = np.squeeze(results)

		top_k = results.argsort()[-5:][::-1]
		labels = self.load_labels(lablelPath)
		for i in top_k:
			if "non porn" == str(labels[i]):
				object_details["non_porn"] = results[i]
			else:
				object_details[str(labels[i])] = results[i]

		return object_details

	def read_tensor_from_image_file(self,file_name, input_height=299, input_width=299, input_mean=0, input_std=255):
		input_name = "file_reader"
		output_name = "normalized"
		file_reader = tf.read_file(file_name, input_name)
		if file_name.endswith(".png"):
			image_reader = tf.image.decode_png(
				file_reader, channels=3, name="png_reader")
		elif file_name.endswith(".gif"):
			image_reader = tf.squeeze(
				tf.image.decode_gif(file_reader, name="gif_reader"))
		elif file_name.endswith(".bmp"):
			image_reader = tf.image.decode_bmp(file_reader, name="bmp_reader")
		else:
			image_reader = tf.image.decode_jpeg(
				file_reader, channels=3, name="jpeg_reader")
		float_caster = tf.cast(image_reader, tf.float32)
		dims_expander = tf.expand_dims(float_caster, 0)
		resized = tf.image.resize_bilinear(dims_expander, [input_height, input_width])
		normalized = tf.divide(tf.subtract(resized, [input_mean]), [input_std])
		sess = tf.Session()
		result = sess.run(normalized)

		return result

	def load_labels(self,label_file):
		label = []
		proto_as_ascii_lines = tf.gfile.GFile(label_file).readlines()
		for l in proto_as_ascii_lines:
			label.append(l.rstrip())
		return label

	
	
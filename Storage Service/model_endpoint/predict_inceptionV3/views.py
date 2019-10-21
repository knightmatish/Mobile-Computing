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
MODEL_PATH = "/Users/nitishmathur/Unimelb/Computing project/Trained_Models/output_graph_inception_run_sep_13.pb"

LABEL_PATH = "/Users/nitishmathur/Unimelb/Computing project/Trained_Models/output_labels_inception_run_sep_13.txt"



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
			object_details = self.predict_image_class(image_path, LABEL_PATH, object_details)
			object_details['url'] = 'http://' + str(IPAddr) + ':8989/media/' + str(image_obj.image) 

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


	def predict_image_class(self, imagePath, labelPath, object_details):
	
		matches = None # Default return to none

		

		# Load the image from file
		image_data = tf.gfile.FastGFile(imagePath, 'rb').read()

		# Load the retrained inception based graph
		with tf.gfile.FastGFile(MODEL_PATH, 'rb') as f:
				# init GraphDef object
				graph_def = tf.GraphDef()
				# Read in the graphy from the file
				graph_def.ParseFromString(f.read())
				_ = tf.import_graph_def(graph_def, name='')
			# this point the retrained graph is the default graph

		with tf.Session() as sess:
			# These 2 lines are the code that does the classification of the images 
			# using the new classes we retrained Inception to recognize. 
			#   We find the final result tensor by name in the retrained model
			start = time.time()
			if not tf.gfile.Exists(imagePath):
				tf.logging.fatal('File does not exist %s', imagePath)
				return matches

			softmax_tensor = sess.graph.get_tensor_by_name('final_result:0')
			#   Get the predictions on our image by add the image data to the tensor
			predictions = sess.run(softmax_tensor,
								{'DecodeJpeg/contents:0': image_data})
			
			# Format predicted classes for display
			#   use np.squeeze to convert the tensor to a 1-d vector of probability values
			predictions = np.squeeze(predictions)

			top_k = predictions.argsort()[-5:][::-1]  # Getting the indicies of the top 5 predictions

			#   read the class labels in from the label file
			f = open(labelPath, 'rb')
			lines = f.readlines()
			labels = [str(w).replace("\n", "") for w in lines]
			print("")
			print ("Image Classification Probabilities")
			#   Output the class probabilites in descending order
			for node_id in top_k:
				human_string = self.filter_delimiters(labels[node_id])
				score = predictions[node_id]
				if "non porn" == str(human_string):
					object_details["non_porn"] = score
				else:
					object_details[str(human_string)] = score
				print('{0:s} (score = {1:.5f})'.format(human_string, score))

			print("")

			answer = labels[top_k[0]]
			print ("Time to classify only-",(time.time()-start))
			return object_details


	def predict_image_class_new(self, imagePath, labelPath, object_details):
	
		matches = None # Default return to none

		

		# Load the image from file
		image_data = tf.gfile.FastGFile(imagePath, 'rb').read()

		# Load the retrained inception based graph
		with tf.gfile.FastGFile(MODEL_PATH, 'rb') as f:
				# init GraphDef object
				graph_def = tf.GraphDef()
				# Read in the graphy from the file
				graph_def.ParseFromString(f.read())
				_ = tf.import_graph_def(graph_def, name='')
			# this point the retrained graph is the default graph

		with tf.Session() as sess:
			# These 2 lines are the code that does the classification of the images 
			# using the new classes we retrained Inception to recognize. 
			#   We find the final result tensor by name in the retrained model
			start = time.time()
			if not tf.gfile.Exists(imagePath):
				tf.logging.fatal('File does not exist %s', imagePath)
				return matches

			softmax_tensor = sess.graph.get_tensor_by_name('final_result:0')
			#   Get the predictions on our image by add the image data to the tensor
			predictions = sess.run(softmax_tensor,
								{'DecodeJpeg/contents:0': image_data})
			
			# Format predicted classes for display
			#   use np.squeeze to convert the tensor to a 1-d vector of probability values
			predictions = np.squeeze(predictions)

			top_k = predictions.argsort()[-5:][::-1]  # Getting the indicies of the top 5 predictions

			#   read the class labels in from the label file
			f = open(labelPath, 'rb')
			lines = f.readlines()
			labels = [str(w).replace("\n", "") for w in lines]
			print("")
			print ("Image Classification Probabilities")
			#   Output the class probabilites in descending order
			for node_id in top_k:
				human_string = self.filter_delimiters(labels[node_id])
				score = predictions[node_id]
				if "non porn" == str(human_string):
					object_details["non_porn"] = score
				else:
					object_details[str(human_string)] = score
				print('{0:s} (score = {1:.5f})'.format(human_string, score))

			print("")

			answer = labels[top_k[0]]
			print ("Time to classify only-",(time.time()-start))
			return object_details

	def filter_delimiters(self,text):
		filtered = text[:-3]
		filtered = filtered.strip("b'")
		filtered = filtered.strip("'")
		return filtered


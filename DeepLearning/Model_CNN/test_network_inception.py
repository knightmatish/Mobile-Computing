
# Importing libraries
import tensorflow as tf
import numpy as np
import argparse
import time


MODEL_PATH = "/mnt/project/InceptionV3/output_graph_inception_run_sep_13.pb"

LABEL_PATH = "/mnt/project/InceptionV3/output_labels_inception_run_sep_13.txt"

# MODEL_PATH = "/home/suraj/Unimelb/Computing_project/Trained_Models/output_graph_inception_run_sep_13.pb"

# LABEL_PATH = "/home/suraj/Unimelb/Computing_project/Trained_Models/output_labels_inception_run_sep_13.txt"

#   Remove ugly characters from strings
def filter_delimiters(text):
	filtered = text[:-3]
	filtered = filtered.strip("b'")
	filtered = filtered.strip("'")
	return filtered


def predict_image_class(imagePath, labelPath):
	
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
			human_string = filter_delimiters(labels[node_id])
			score = predictions[node_id]
			print('{0:s} (score = {1:.5f})'.format(human_string, score))

		print("")

		answer = labels[top_k[0]]

		print ("time to classify-",(time.time()-start))
		return answer

# Get the path to the image you want to predict.  
if __name__ == '__main__':
	
	# Ensure the user passes the image_path
	parser = argparse.ArgumentParser(description="Process arguments")
	parser.add_argument(
	  'image_path',
	  type=str,
	  default='',
	  help='Path of image to classify.'
	)
	args = parser.parse_args()

	# We can only handle jpeg images.   
	if args.image_path.lower().endswith(('.jpg', '.jpeg')):
		# predict the class of the image
		predict_image_class(args.image_path, LABEL_PATH)
	else:
		print('File must be a jpeg image.')
	

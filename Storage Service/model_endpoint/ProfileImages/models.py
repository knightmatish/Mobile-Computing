import pytz
from django.contrib.auth.base_user import BaseUserManager
from django.contrib.auth.models import AbstractUser
from django.db import models
from django.urls import reverse
# Create your models here.

def nameFile(filename):
	return '/'.join(['images', filename])

class UploadImage(models.Model):
	name = models.CharField(max_length=200)
	image = models.ImageField(upload_to='profile_pics/')
	def __str__(self):
		print ("-"*10,self.image.name)
		return self.image.name
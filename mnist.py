'''必要なデータをインポート'''
import tensorflow as tf
import numpy as np
import sys
from PIL import Image
import subprocess

'''データフローグラフの構築'''
with tf.device('/cpu:0'):
	x = tf.placeholder(tf.float32, shape=[None,784])
	
	# 784ノード -> 625ノード
	w_h = tf.Variable(tf.random_normal([784,625], mean=0.0, stddev=0.05))
	b_h = tf.Variable(tf.zeros([625]))
	h = tf.matmul(x,w_h) + b_h
	h = tf.sigmoid(h)
	
	# 625ノード -> 10ノード
	w_o = tf.Variable(tf.random_normal([625,10], mean=0.0, stddev=0.05))
	b_o = tf.Variable(tf.zeros([10]))
	out = tf.matmul(h,w_o) + b_o
	
	logit = tf.argmax(out,1)
	'''データフローグラフ構築終了'''

	'''作成したデータフローグラフに値を流す'''
	with tf.Session() as sess:
		subprocess.call(['display', '/home/matsumura/GPU_lecture/mnist_data/'+sys.argv[1]+'.png'])
		# 初期化
		saver = tf.train.Saver()
		saver.restore(sess,'/home/matsumura/GPU_lecture/model/mnist')
		
		# 画像読み込み
		img = np.array(Image.open('/home/matsumura/GPU_lecture/mnist_data/'+sys.argv[1]+'.png'))
		img = np.reshape(img,[-1,784])
		
		inference = sess.run(logit,feed_dict={x:img})
		print('\n result : %d\n'%inference)
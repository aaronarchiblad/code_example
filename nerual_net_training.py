'''
This experiment shows that how initialization affects the gradients during training. Detail and mathematical reasoning is in alg 3 note
'''

import tensorflow as tf
import numpy as np
from matplotlib import pyplot as plt
from sklearn.model_selection import train_test_split

# How does initialization affect neural network during training
w1 = tf.Variable(tf.random.normal(shape=[100,100], mean=0, stddev=0.1))
w2 = tf.Variable(tf.random.normal(shape=[100,100], mean=0, stddev=0.1))

x1 = tf.ones(shape=[1, 100])


a1 = tf.matmul(x1, w1)
a2 = tf.matmul(a1, w2)

logits = tf.nn.softmax(a2)

ls = []
for i in range(100):
    with tf.Session() as sess:
        sess.run(tf.global_variables_initializer())
        a = sess.run(a1[0])
        ls.append(np.max(a) - np.min(a))
        result = sess.run(logits)

plt.plot(ls)
np.mean(ls)
result
np.max(result) - np.min(result)
np.round(-np.log(result),2)



# How does mini-batch size affect neural network during the training
#x = tf.zeros(shape=[2, 5])
x = tf.ones(shape=[2, 5])
x1 = tf.zeros(shape=[99,5])
x2 = tf.ones(shape=[1,5])
x = tf.concat([x1, x2], axis=0)
y = np.repeat([[1.0,0.0,0.0]], repeats=100, axis=0)

x_train = tf.placeholder(tf.float32, shape=[None, 5])
y_train = tf.placeholder(tf.float32, shape=[None, 3])

w = tf.Variable(tf.random.normal(shape=[5,3], mean=0, stddev=1, seed=1))

a = tf.nn.relu(tf.matmul(tf.cast(x_train,tf.float32),w))

loss = tf.nn.softmax_cross_entropy_with_logits_v2(logits=a, labels=y_train)
cost = tf.reduce_mean(loss)

gradient = tf.gradients(loss, w)

optimizer = tf.train.GradientDescentOptimizer(learning_rate=1).minimize(cost)

with tf.Session() as sess:
    sess.run(tf.global_variables_initializer())
    for i in range(10):
        x_batch, _, y_batch, _ = train_test_split(x, y, train_size=10)
        feed_dict_train = {x_train:x_batch, y_train:y_batch}
        _, c = sess.run([optimizer, gradient])

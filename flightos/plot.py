import matplotlib.pyplot as plt
import numpy as np


dt = np.loadtxt('data.txt')

# first line is kp, ki and kd
kp = ki = kd = 0
#[kp, ki, kd] = dt[0]
#dt = dt[1:]

#normalize error
#dt[:, 1] = -1 + 2 * (dt[:, 1] - np.min(dt[:, 1])) / (np.max(dt[:, 1]) - np.min(dt[:, 1]))

fig = plt.figure()
ax1 = fig.add_subplot(111)

ax1.plot(dt[:,0], dt[:,1], c='r', label='Error')
ax1.plot(dt[:,0], dt[:,2], c='g', label='Output')

ax1.set_title("Yaw PID Controller (Kp: {}, Ki: {}, Kd: {})".format(kp, ki, kd))
ax1.set_xlabel('Time')
ax1.set_ylabel('Centerline Angle')
leg = ax1.legend()

plt.grid()
#plt.savefig("outputs/{}-{}-{}.png".format(kp, ki, kd))
plt.show()

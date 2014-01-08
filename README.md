# Eureka 
An Internet of Things button powered by an [Electric Imp](http://www.electricimp.com "Electric Imp").

![the Eureka button](https://raw.github.com/mezelve/eureka/gh-pages/media/eureka_04.jpg)

Each time I have a good idea, I'll press the Eureka button. A random precomposed tweet will be twittered by [@yoo_ree_kuh](http://www.twitter.com/yoo_ree_kuh) to capture this precious moment. At the same time a counter at [Xively](http://www.xively.com) gets updated, this data can/will be used later.

---

### Software
The Electric Imp system has 2 scripts. One that runs on the device itself and one that runs on a server in the cloud - called the agent. The first one is basicalty there to interact with the IO pins, the 2nd one can send and receive data from/to the Imp and interact with other webservices like Twitter and Xively.

#### Agent code
Here I've used the 2 classes for Twitter and Xively (MIT license) provided by Electric Imp.
- [Twitter Search](https://github.com/electricimp/reference/tree/master/webservices/twitter)
- [Xively Electric Imp Sample Code](https://github.com/electricimp/reference/tree/master/webservices/xively)

You'll also have to create an app for your Twitter account to be able to send tweets: [https://dev.twitter.com](https://dev.twitter.com)

#### Device code
The button is connected to pin 1, which is the wakeup pin. This means that the Eureka button is most of the time asleep and the batteries will last longer, but also that the Imp first needs to wakeup before it can send the timestamp to the agent.

---

### Hardware

#### Components
- an Electric Imp
- an April breakout board
- a push button - I've used a 60mm Arcade Button from Adafruit (the Led is attached to pin 9)
- a switch
- a batterypack or a LiPo battery
- a laser cut case
- screws, headers, hookup wire ...

I modified the Arcade button. I replaced the Led and its resistor (a 100ohm one).

![Fritzing](https://raw.github.com/mezelve/eureka/gh-pages/media/eureka.jpg)

![the main parts](https://raw.github.com/mezelve/eureka/gh-pages/media/eureka_02.jpg)

![almost assembled](https://raw.github.com/mezelve/eureka/gh-pages/media/eureka_03.jpg)

#### Case
I've order a laser cut 3mm plywood case at [Formulor](http://www.formulor.de). You can find the SVG files in the hardware/case folder. Make sure to check the dimensions of your switch and its mounting holes.

![the laser cut parts](https://raw.github.com/mezelve/eureka/gh-pages/media/eureka_01.jpg)

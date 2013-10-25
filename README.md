em-so-reuseport
===============

Eventmachine with SO_REUSEPORT

Requires eventmachine eventmachine/eventmachine@cfb1f71a35b1a10e5821bca9841fee3080ec1685 (Autumn 2013) to add em_attach_server

Run as `ruby socketserver2.rb` - the original process will fork twice, and create 2 subprocesses, which will 
both bind to port 8200. If you connect to port 8200 with nc - like this `echo beep | nc -v 127.0.0.1 8200`
several times, you will see that the different connections arrive at different processes. 



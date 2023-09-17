# Attention
For adguard home you need to use these commands to make sure to stop the default server and change the port of the adguard

```
sudo ./AdguardHome -s stop
```
```
sudo ./AdguardHome -s start --web-addr 0.0.0.0:3330
```

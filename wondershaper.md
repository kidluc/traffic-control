## Giới hạn băng thông client bằng wondershaper
Mô hình gồm 1 Linux Router và 1 Client.  
Router: 10.0.3.254  
Client: 10.0.3.100  
Cài đặt wondershaper trên Router
```
sudo apt-get install wondershaper
```
Test tốc độ mạng trên client khi chưa sử dụng wondershaper, ở đây dùng iperf để test. Cài đặt iperf trên cả Router và Client
```
sudo apt-get install iperf
```
Để Router lắng nghe
```
iperf -s
```
Trên Client test tốc độ mạng
```
iperf -c 10.0.3.254
```
Kết quả nhận được bandwidth là 4.87 Gbits/s  
![beforewondershaper89c2a0c766e1ebfb.png](http://sv1.upsieutoc.com/2017/11/17/beforewondershaper89c2a0c766e1ebfb.png)  
Bây giờ thử dùng wondershaper để giới hạn bandwidth của Client thành 1MB~8192Kb down và 1MB~8192Kb up
```
wondershaper ens38 8192 8192
```
Thử test lại tốc độ mạng của client
```
iperf -c 10.0.3.254
```
![afterwondershaper.png](http://sv1.upsieutoc.com/2017/11/17/afterwondershaper.png)  
Như chúng ta đã thấy bandwidth của Client đã bị giới hạn lại nhưng vẫn không đúng như chúng ta mong muốn do nhiều yếu tố, bạn có thể chỉnh lại tốc độ down, up trong câu lệnh wondershaper để có thể có bandwidth như ý muốn.

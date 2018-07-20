# Queue
Các packet vào và ra khỏi mạng sẽ được xếp hàng đợi trước khi được nhận hoặc truyền tương ứng.

# Traffic Control Elements (Các yếu tố điều khiển lưu lượng)
### 1. Shaping  
Shaping trì hoãn việc truyền các packet để đáp ứng tốc độ truyền dữ liệu. Đây là cách đảm bảo dữ liệu đầu ra không vượt quá giá trị mong muốn. Shaping được thực hiện ở đi ra.  
### 2. Scheduling
Scheduling quyết định packet nào sẽ được truyền đi tiếp theo. Điều này được thực hiện bằng cách sắp xếp lại các gói tin trong hàng đợi.  
### 3. Policing
Policing là đo các packet nhận được trên một interface limit nó đến 1 giá trị mong muốn. Các packet có thể được phân loại hoặc drop. Policy được thực hiện ở khi đi vào.  
### 4. Dropping
Sau khi lưu lượng vượt quá giá trị được xác định trước, các packet sẽ bị drop. Drop được thực hiện ở cả lối vào và lối ra.  

# Traffice Control Components (Các thành phần điều khiển lưu lượng)
### 1. qdiscs  
qdisc quyết định packet nào được send, packet nào delay, packet nào drop...  
qdisc có 2 loại classless và classful qdisc: classless không chứa class và classful chứa nhiều class, một số các class chứa thêm qdísc.  
### 2. Class
Class là một sub-qdisc. Class có thể chứa Class khác. Sử dụng Class, chúng ta có thể cấu hình QoS chi tiết hơn. Khi packet nhận được bởi một qdisc, chúng có thể được xếp hàng đợi ở qdisc bên trong các Class. Khi kernel muốn truyền packet, các packet của một số lớp nhất định có thể được đưa ra trước, do đó có thể ưu tiên một số loại lưu lượng truy cập.  
### 3. Filer 
Khi một qdisc với Class nhận được một packet, nó phải được quyết định nó được queue vào Class nào. Filter dùng để phân loại các packet.  

# Classless Queuing Disciplines
### FIFO (pfifo, bfifo)
Thuật toán FIFO không thực hiện việc shaping hoặc sắp xếp lại các package, nó chỉđơn giản là truyền các package ngay khi có thể khi nó nhận được package và xếp các package vào hàng đợi. Đây cũng là qdisc được sử dụng bên trong tất cả các Class mới được tạo ra.  
FIFO phải có giới hạn về kích thước (buffer size) để ngăn chặn việc bị tràn trong TH tốc độ dequeue package không bằng tốc độ nó nhận được package. Linux thực hiện 2 qdisc FIFO cơ bản, dựa trên byte hoặc dựa trên package.  
### pfifo_fast
pfifo_fast là qdisc mặc định cho tất cả interface trong Linux. Dựa trên qdisc FIFO thông thường, qdisc này cung cấp một số ưu tiên.  
Nó có 3 bands, band 0 cho lưu lượng từ ứng dụng tương tác, các ứng dụng muốn có độ trễ thấp. Band 1 cho việc truyền tổng lực (best effort) và các dịch vụ bình thường. Band 2 để truyền dữ liệu có dung lượng lớn. Dựa trên trường ToS trong packet, nó sẽ được đặt ở 1 trong 3 band. Đầu tiên, tất cả các packet trong band 1 sẽ được truyền đi, khi không còn packet nào trong band 0 thì các packet trong band 1 sẽ được truyền đi. Tương tự với band 2.  
### Stochastic Fair Queuing 
SFQ lập kế hoạch truyền package đảm bảo sự công bằng để mỗi flow có thể gửi dữ liệu lần lượt. Nó sử dụng hàm băm để tách lưu lượng truy cập thành FIFO riêng biệt. Bởi vì có khả năng cho sự bất công trong sự lựa chọn hàm băm, chức năng này được thay đổi định kỳ (tham số perturb tính bằng giây)  
### Extended Stochastic Fair Queuing 
qdisc này cũng giống SFQ nhưng nó cho phép kiểm soát được nhiều thông số hơn, ESFQ cho phép người dùng kiểm soát thuật toán băm nào được sử dụng để phân phối truy cập vào băng thông mạng.  
### Token Bucket Filter
TBF là một qdisc truyền các packet với tốc độ không vượt quá tốc độ được cấu hình nhưng có thể cho phép các burst ngắn vượt quá tốc độ này.  
TBF bao gồm một bucket được lấp đầy bởi các token. Bucket size là số token nó có thể lưu trữ.  
Mỗi package tiêu thụ một số token.  Khi tạo, TBF được lưu trữ với các token tương ứng với lượng truy cập có thể burst trong 1 lần. Nếu không có token thì package sẽ được xếp hàng đợi, TBF sẽ tính toán để bù các token vào và sẽ thắt chặt việc nhận package cho đến khi package đầu tiên trong hàng đợi được gửi đi.  

# Classful Queuing Disciplines
### Flow within classful qdisc & class
Khi package đến qdisc, qdisc sẽ gọi filter để lọc package rồi gửi đến các class bên dưới. Các class sẽ tiếp tục filter để xem có phân loại được package tiếp không, nếu không thì class nó tiếp nhận package đó.  
### Roots, handles, siblings & parents
Mỗi interface có egress (root qdisc) và ingress (qdisc). Mỗi qdisc và class được gán một handle gồm major:minor. Class cần có số major giống parent ở trên.  
Khi quyết định dequeue một package để truyền ra interface, root qdisc gửi dequeue request đến tất cả các class bên dưới, các class đó tiếp tục gửi queries xuống dưới để cố gắng dequeue package. 
### Hierarchical Token Bucket
Khi enqueue package, HTB bắt đầu từ root và sử dụng các phương pháp filter để xác định class nào sẽ nhận được package.  
Qdisc có các tham só như:  
- parent major:minor | root: Xác định vị trí của cá thể được cấu hình.  
- handle major: : chỉ định handle có qdisc.  
- default minor-id: Các lưu lượng không được phân loại sẽ được enqueue vào minor-id.  

Class có các tham số như:  
- parent major:minor : Vị trí của class này trong hệ thống phân cấp.  
- classid major:minor : Giống như qdisc, class cũng cần có tên, major sẽ là major của qdisc nó thuộc về.  
- prio priority: Trong quá trình round robin, class có priority thấp nhấp sẽ được dequeue trước.  
- rate rate: bandwidth tối đa của class và các class con.  
- ceil rate: bandwidth tối đa class có thể sử dụng, việc này sẽ giới hạn bandwidth class có thể mượn.  
- burst byte: Số byte có thể được burst ở tốc độ ceil.  
- cburst byte: Số byte có thể được burst ở tốc độ nhanh nhất mà interface có thể truyền.  

### Priority Scheduler
Khi package đi vào PRIO qdisc, package sẽ được đưa vào class bằng cách filter, mặc định thì sẽ có 3 class được tạo ra.  
Khi sẵn sàng để truyền package, class đầu tiên sẽ được kiểm tra, nếu có package thì sẽ được truyền, nếu không có package thì class kế tiếp được kiểm tra...  
Có 2 thông số chính bands, priomap 
### Class Based Queuing
CBQ cũng hoạt động giống PRIO theo nghĩa là những class sẽ có những ưu tiên khác nhau và số ưu tiên thấp hơn sẽ được dequeue trước.  
Mỗi khi cần dequeue package, một quá trình weighted round-robin (WRR) bắt đầu, bắt đầu bởi các class có priority thấp. Sau đó chúng được nhóm lại và truy vấn nếu có sẵn dữ liệu. Sau khi một class đã được dequeue một số byte, class kế tiếp sẽ được thử.  
Các thông số kiểm soát quá trình WRR:  
- allot: là số byte mà qdisc có thể dequeue trong mỗi round.  
- prio: Các class có độ ưu tiên thấp hơn được thử trước.  
- weight: weight được nhân với **allot** để xác định số lượng dữ liệu có thể được gửi trong mỗi round.  

Bên cạnh việc hạn chế lưu lượng truy cập, CBQ có thể chỉ định các class có thể mượn bandwidth của class khác:  
- Isolated: Nếu cấu hình isolated sẽ không cho mượn bandwidth.  
- Sharing: Cấu hình Sharing sẽ cho các class khác mượn bandwidth.  
- Bounded: Cấu hình bounded có nghĩa là nó sẽ không mượn bandwidth từ các class khác.  
- Borrow: Cấu hình borrow cho phép mượn bandwidth từ class khác.  


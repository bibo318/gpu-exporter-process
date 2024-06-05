# Hướng dẫn Sử dụng Exporter Nvidia Process Metrics

## Chức năng

File mã nguồn `exporter-nvidia-process-metricsStart.py` và `nvidia-smi-ps.sh` cung cấp một exporter đo lường hiệu suất cho các tiến trình đang sử dụng bộ nhớ GPU trên hệ thống NVIDIA. Nó thu thập thông tin về các tiến trình đang chạy trên GPU và xuất chúng dưới dạng metrics Prometheus.

## Dữ liệu Trích xuất từ GPU

Exporter này trích xuất các thông tin sau từ GPU:

- UUID: UUID của GPU.
- Index: Chỉ số của GPU.
- Memory: Bộ nhớ tổng của GPU.
- PID: Process ID của tiến trình.
- User: Người dùng đang chạy tiến trình.
- Mem_use_gpu: Bộ nhớ GPU được sử dụng bởi tiến trình.
- CPU_percentage: Phần trăm CPU sử dụng bởi tiến trình.
- Process_command: Lệnh tiến trình.
- Container_name: Tên container Docker (nếu có).
- Docker_image: Ảnh Docker của tiến trình (nếu có).

## Câu lệnh Query ở Prometheus

Để truy vấn các metrics này trong Prometheus, bạn có thể sử dụng câu lệnh sau:
- nvidia_smi_process

Để thay đổi tần suất thu thập dữ liệu, bạn có thể sửa đổi câu lệnh trong file python.

    # Cấu hình và chạy công việc thu thập dữ liệu mỗi 30 giay
    schedule.every(30).seconds.do(collect_metrics)
    
    # Cấu hình và chạy công việc thu thập dữ liệu mỗi 5 phút
    #schedule.every(5).minutes.do(collect_metrics)

## Port dịch vụ
Thay đổi dòng sau trong file python:   

    # Chạy Flask app trên cổng 9836
        app.run(host='0.0.0.0', port=9836)  

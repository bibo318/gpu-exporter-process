from flask import Flask
from prometheus_client import generate_latest, Gauge
import subprocess
import schedule
import time

app = Flask(__name__)

# Khởi tạo các metrics
gpu_metric = Gauge('nvidia_smi_process', 'GPU Usage', ['uuid', 'index', 'memory', 'pid', 'user', 'mem_use_gpu', 'cpu_percentage', 'process_command', 'container_name', 'docker_image'])

def collect_metrics():
    # Chạy script Bash và thu thập đầu ra
    result = subprocess.run(['./nvidia-smi-ps.sh'], stdout=subprocess.PIPE, text=True)
    lines = result.stdout.splitlines()

    # Xử lý từng dòng và cập nhật metrics
    for line in lines:
        fields = line.split('\t')
        if len(fields) < 10:
            continue
        uuid, index, memory = fields[:3]
        pid, user, mem_use_gpu, cpu_percentage, process_command = fields[3:8]
        container_name, docker_image = fields[8:10]
        gpu_metric.labels(uuid, index, memory, pid, user, mem_use_gpu, cpu_percentage, process_command, container_name, docker_image).set(1)

@app.route('/metrics')
def metrics():
    return generate_latest()

if __name__ == '__main__':
    # Chạy thu thập dữ liệu lần đầu tiên
    collect_metrics()
    
    # Cấu hình và chạy công việc thu thập dữ liệu mỗi 30 giay
    schedule.every(30).seconds.do(collect_metrics)
    # Cấu hình và chạy công việc thu thập dữ liệu mỗi 5 phút
    #schedule.every(5).minutes.do(collect_metrics)

    # Chạy Flask app trên cổng 9836
    app.run(host='0.0.0.0', port=9836)

    # Vòng lặp chạy lịch trình
    while True:
        schedule.run_pending()
        time.sleep(1)

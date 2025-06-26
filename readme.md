## 补丁及使用

```sh
local_image_set_arch.patch

ccb local-build --local-image=openeuler-24.03-lts-sp2:rv --cp /root/0625/openEuler.repo  os_project=openEuler-24.03-LTS-SP2:everything package=hostname arch=riscv64
#--cp path，可选参数，因为2403sp2镜像的下载源有问题，所以需要自己准备下载源进行覆盖
#arch riscv64 可选参数，指定容器启动的架构，不设置则为主机自带架构

#注：本次补丁可能会影响原有local-build从官网下载的镜像，也是因为镜像里面下载源有问题，自己准备下载源进行覆盖可以解决。
```



## Ubuntu内安装使用

```sh
#下载解压包，进入解压出来的根目录
#https://gitee.com/src-openeuler/ccb/
#原来的补丁看情况需要自己手动下载，打补丁

#复制Makefile到项目根目录
root@oe:~/ccb# ls
lib  LICENSE  Makefile  README.md  sbin  tests

#安装，然后按照提示操作
make install
source /usr/local/lib/ccb/lib/env.sh
#填写账号密码
vim ~/.config/cli/defaults/config.yaml
#主机至少需要以下组件 
#apt install ruby ruby-rest-client curl wget docker-cli patch

#打补丁（可选） local_image_set_arch.patch （包括选择本地映像和设置架构以及挂载）
#默认安装是这个位置,复制补丁过去
#cp local_image_set_arch.patch /usr/local/lib/ccb
cd /usr/local/lib/ccb
patch -p1 < local_image_set_arch.patch

#使用示例
#2403sp2 x86_64
#因为官方镜像里面下载源有问题，所以需要自己准备下载源
#http://121.36.84.172/dailybuild/EBS-openEuler-24.03-LTS-SP2/openeuler-2025-06-26-12-22-01/docker_img/x86_64/openEuler-docker.x86_64.tar.xz
ccb local-build --local-image=openeuler-24.03-lts-sp2:latest --cp /root/0626/openEuler.repo os_project=openEuler-24.03-LTS-SP2:everything package=pcre2 2>&1 | tee -a build_output.log

#2403sp2 riscv64
#http://121.36.84.172/dailybuild/EBS-openEuler-24.03-LTS-SP2/openeuler-2025-06-24-19-53-02/docker_img/riscv64/openEuler-docker.riscv64.tar.xz
ccb local-build --local-image=openeuler-24.03-lts-sp2:rv --cp /root/0625/openEuler.repo  os_project=openEuler-24.03-LTS-SP2:everything package=hostname arch=riscv64 2>&1 | tee -a build_output.log

#2403sp1 x86_64
#https://mirror.nyist.edu.cn/openeuler/openEuler-24.03-LTS-SP1/docker_img/x86_64/openEuler-docker.x86_64.tar.xz
ccb local-build --local-image=openeuler-24.03-lts-sp1:latest os_project=openEuler-24.03-LTS-SP1:everything package=pcre2 2>&1 | tee -a build_output.log

#2403sp1 riscv64
#https://mirror.nyist.edu.cn/openeuler/openEuler-24.03-LTS-SP1/docker_img/riscv64/openEuler-docker.riscv64.tar.xz
ccb local-build --local-image=openeuler-24.03-lts-sp1:rv os_project=openEuler-24.03-LTS-SP1:everything package=hostname arch=riscv64 2>&1 | tee -a build_output.log

#hub.docker
#2403lts x86_64
ccb local-build --local-image=openeuler/openeuler:24.03-lts os_project=openEuler-24.03-LTS:everything package=pcre2 2>&1 | tee -a build_output.log

#2403lst riscv64
#https://mirror.nyist.edu.cn/openeuler/openEuler-24.03-LTS/docker_img/riscv64/openEuler-docker.riscv64.tar.xz
ccb local-build --local-image=openeuler-24.03-lts:rv os_project=openEuler-24.03-LTS:everything package=hostname arch=riscv64 2>&1 | tee -a build_output.log
#没跑成功，大概是镜像有问题
ImportError: libstdc++.so.6: cannot open shared object file: No such file or directory
Traceback (most recent call last):
  File "/usr/bin/dnf", line 61, in <module>
    from dnf.cli import main
  File "/usr/lib/python3.11/site-packages/dnf/__init__.py", line 30, in <module>
    import dnf.base
  File "/usr/lib/python3.11/site-packages/dnf/base.py", line 29, in <module>
    import libdnf.transaction
  File "/usr/lib64/python3.11/site-packages/libdnf/__init__.py", line 8, in <module>
    from . import error
  File "/usr/lib64/python3.11/site-packages/libdnf/error.py", line 10, in <module>
    from . import _error
ImportError: libstdc++.so.6: cannot open shared object file: No such file or directory
```

## 容器内使用

构建镜像：

```sh
docker build -t oe:ccb .
```
启动容器：

```sh
docker run -itd --name oe --privileged -v /var/run/docker.sock:/var/run/docker.sock -v /tmp:/tmp oe:ccb bash
```

设置euler网站的账号密码，注意特殊字符（）

```sh
#进入容器内部操作
vim ~/.config/cli/defaults/config.yaml
```

下载镜像进行构建：

```sh
#构建成功
ccb local-build os_project=openEuler-24.03-LTS:everything package=pcre2 2>&1 | tee -a build_output.log
```

使用补丁(可选):

```sh
#主机操作
docker cp select_image.patch oe:/usr/libexec/ccb/
docker exec -it oe bash
#容器内操作
cd /usr/libexec/ccb
patch -p1 < select_image.patch

#之后，就可以使用本地镜像进行构建了，构建的内容还是保存在主机相同的位置,见构建log的输出
#上面的构建本地已经有 5542887c99f6 这个镜像了
#主机 docker tag 5542887c99f6 2403lts:1
#构建成功
ccb local-build --local-image=2403lts:1 os_project=openEuler-24.03-LTS:everything package=hostname 2>&1 | tee -a build_output.log
#构建成功
ccb local-build --local-image=5542887c99f6 os_project=openEuler-24.03-LTS:everything package=hostname 2>&1 | tee -a build_output.log

#失败，找不到镜像
ccb local-build --local-image=1234567890 os_project=openEuler-24.03-LTS:everything package=hostname 2>&1 | tee -a build_output.log
#失败，找不到镜像
ccb local-build --local-image=nonexist:now os_project=openEuler-24.03-LTS:everything package=hostname 2>&1 | tee -a build_output.log
```

这样的话，在容器内使用ccb就和在主机使用ccb没有区别了



## 下载源

### 2403sp2 x86_64

```sh
[OS]
name=OS
baseurl=http://121.36.84.172/dailybuild/EBS-openEuler-24.03-LTS-SP2/openeuler-2025-06-26-12-22-01/OS/$basearch/
metalink=https://mirrors.openeuler.org/metalink?repo=$releasever/OS&arch=$basearch
metadata_expire=1h
enabled=1
gpgcheck=1
gpgkey=http://121.36.84.172/dailybuild/EBS-openEuler-24.03-LTS-SP2/openeuler-2025-06-26-12-22-01/OS/$basearch/RPM-GPG-KEY-openEuler

[everything]
name=everything
baseurl=http://121.36.84.172/dailybuild/EBS-openEuler-24.03-LTS-SP2/openeuler-2025-06-26-12-22-01/everything/$basearch/
metalink=https://mirrors.openeuler.org/metalink?repo=$releasever/everything&arch=$basearch
metadata_expire=1h
enabled=1
gpgcheck=1
gpgkey=http://121.36.84.172/dailybuild/EBS-openEuler-24.03-LTS-SP2/openeuler-2025-06-26-12-22-01/everything/$basearch/RPM-GPG-KEY-openEuler

[EPOL]
name=EPOL
baseurl=http://121.36.84.172/dailybuild/EBS-openEuler-24.03-LTS-SP2/openeuler-2025-06-26-12-22-01/EPOL/main/$basearch/
metalink=https://mirrors.openeuler.org/metalink?repo=$releasever/EPOL/main&arch=$basearch
metadata_expire=1h
enabled=1
gpgcheck=0
```

### 2403sp2 riscv64

```sh
[OS]
name=OS
baseurl=http://121.36.84.172/dailybuild/EBS-openEuler-24.03-LTS-SP2/openeuler-2025-06-24-19-53-02/OS/riscv64/
metadata_expire=1h
enabled=1
gpgcheck=0

[everything]
name=everything
baseurl=http://121.36.84.172/dailybuild/EBS-openEuler-24.03-LTS-SP2/openeuler-2025-06-24-19-53-02/everything/riscv64/
metadata_expire=1h
enabled=1
gpgcheck=0

[EPOL]
name=EPOL
baseurl=http://121.36.84.172/dailybuild/EBS-openEuler-24.03-LTS-SP2/openeuler-2025-06-24-19-53-02/EPOL/main/riscv64/
metadata_expire=1h
enabled=1
gpgcheck=0
```


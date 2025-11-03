ZCU106 design files for PS and PL based 10G Ethernet !!!

This repository contains ZCU106 design files for PS and PL based 10G Ethernet on a rolling release.

A brief guide on how to bring up the operating system, customize the kernel and devicetree to identify all peripherals.

A guide on how to test all peripherals on the above custom circuit.

## Authors

Gradien-MTA

## Appendix

1. Project Vivado
2. Schematic
3. Setup environment and build OS
4. Custom Petalinux
5. Custom Devicetree
6. Custom Kernel
7. Custom Rootfs
8. Build and Test Peripherals

## 1. Project Vivado

Included in source

## 2. Schematic

Included in source

## 3. Setup environment and build OS

First, Open your Ubuntu Terminal and run:

```bash
source /opt/petalinux-v2023.2/settings.sh
```

Then let’s create the directories where we are going to put the provided “XSA“ file.

```bash
mkdir zcu106_10g_fpgalover
mkdir zcu106_10g_fpgalover/binaries
cp top.xsa zcu106_10g_fpgalover/binaries/top.xsa
cd zcu106_10g_fpgalover
```

Now let’s create the base project, based on the zynqMP template.

```bash
petalinux-create --type project --template zynqMP --name ethernet10G_zcu106
Then => cd ethernet10G_zcu106/
```

Now, let’s proceed to get our hardware description and adjust our petalinux recipe according to our hardware

```bash
petalinux-config --get-hw-description=../binaries/top.xsa
```

## 4. Custom Petalinux

Go to DTG Settings->MACHINE_NAME and change the name for “zcu106-reva”

```bash
Note: Set CONFIG_SUBSYSTEM_MACHINE_NAME as required. The possible values are: ac701-full, kc705-lite, zc1751-dc1, zc706, zcu102-revb, zedboard, ac701-lite, kcu105, zc1751-dc2, zcu102-rev1.0, kc705-full, zc702, zcu102-reva, zcu104-reva, zcu104-revc and zcu106-reva. In petalinux-config DTG Settings ---> (template) MACHINE_NAME, change the template to any of the above mentioned possible value.
```

Unmark the image packaging configuration if you do not intend to use the tftp server.

```bash
Image Packaging Configuration --> [ ]Copy final images to tftpboot
```

Now you can exit and save the configurations

You should see that the structure of your project was created successfully.

## 5. Custom Devicetree

Now we will modify the device tree

```bash
nano project-spec/meta-user/recipes-bsp/device-tree/files/system-user.dtsi
```

The device tree

```bash
/include/ "system-conf.dtsi"
/  {
 chosen {
  bootargs = " earlycon console=ttyPS0,115200 clk_ignore_unused root=/dev/ram0 rw cpuidle.off=1";
  stdout-path = "serial0:115200n8";
 };
};
&i2c1 {
    status = "okay";
    clock-frequency = <400000>;
    i2c-mux@74 { /* u34 */
        compatible = "nxp,pca9548";
        #address-cells = <1>;
        #size-cells = <0>;
        reg = <0x74>;
        i2c@3 { /* i2c mw 74 0 8 */
            #address-cells = <1>;
            #size-cells = <0>;
            reg = <3>;
            si570_2: clock-generator@5d {
                #clock-cells = <0>;
                compatible = "silabs,si570";
                reg = <0x5d>;
                temperature-stability = <50>;
                factory-fout = <156250000>;
                clock-frequency = <156250000>;
            };
        };
    };
};
```

## 6. Custom Kernel

Now you can configure the kernel.

Remove from the configurations the CPU Idle management

```bash
CPU Power Management ---> CPU Idle --->[ ] CPU idle PM support
```

Make sure that you add any driver of feature to the Kernel you might need, exit and save.

Now let’s copy the folder provided from the FPGA repository “recipes-kernel” under the folder “meta-user/“

```bash
cp -r recipes-kernel project-spec/meta-user/
```

If you open the file bsp.cfg, you will see that the Xilinx PHY has been added for the Linux configuration.

```bash
nano meta-user/recipes-kernel/linux/linux-xlnx/bsp.cfg
CONFIG_XILINX_PHY=y
# CONFIG_XILINX_DMA is not set
```

Now let’s also copy the folder “recipes-core“ under “meta-user/“ which contain some initialization files for the network interfaces of the ZCU106

```bash
cp -r recipes-core project-spec/meta-user/
```

You can explore and see what they contain.

## 7. Custom Rootfs

Now, let’s go back to configure the rootfs, with the command:

Now it is time to configure the user options of the project, we first will do it manually

```bash
edit the file “project-spec/meta-user/conf/user-rootfsconfig“
nano project-spec/meta-user/conf/user-rootfsconfig
CONFIG_iperf3
CONFIG_ethtool
CONFIG_phytool
```

```bash
petalinux-config -c rootfs
```

Add any package you would like to add to the rootfs, some suggestions would be:

```bash
Filesystem Packages   --->
   admin--->sudo--->[*] sudo 
   base   --->i2c-tools   --->[*] i2c-tools
   base   --->iproute2   --->[*] iproute2 
   base   --->netbase   --->[*] netbase
   base   --->update-rc.d   --->[*] update-rc.d 
   base   --->util-linux   --->[*] util-linux
   base   --->tar --->[*] tar
   net   --->netcat   --->[*] netcat
   console -->network   --->socat   --->[*] socat 
   console -->network   --->wget   --->[*] wget
   console -->network   --->ethtool   ---> [*] ethtool 
   console -->utils   --->unzip   --->[*] unzip 
   console -->utils   --->zip   --->[*] zip 
   console -->utils   --->vim   --->[*] vim
   misc   --->iptables   ---> [*] iptables
   misc   --->net-tools   --->[*] net-tools

Image Features  --->[*] auto-login
user packages   ---> [*] ethtool
user packages   ---> [*] iperf3 
user packages   ---> [*] myapp-init
user packages   ---> [*] phytool

Petalinux Package Groups  --->
   packagegroup-petalinux   --->[*] packagegroup-petalinux
```

Exit and Save.

## 8. Build and Test Peripherals

Now we can build petalinux using the following command

```bash
petalinux-build
```

Once built, we need to create the BOOT.BIN file, which contains the bit, the fsbl, the u-boot, and the pmufw.

```bash
petalinux-package --boot --fsbl images/linux/zynqmp_fsbl.elf --u-boot images/linux/u-boot.elf --pmufw images/linux/pmufw.elf --fpga images/linux/system.bit --force
```

Now you can copy the files to your SD card

```bash
cp images/linux/BOOT.BIN <sd-path>
cp images/linux/image.ub <sd-path>
cp images/linux/boot.scr <sd-path>
umount <sd-path>
```

Now connect your SD-card back to the ZCU106, and open the Terminal using Minicom or any other way you have to do so.

Do not forget to connect your 10Gbps Ethernet cable, the led should be lit

List the interfaces

```bash
ifconfig
```

You should see, that the eth1 was given an IP:

```bash
root@ethernet10G_zcu106:~# ifconfig
eth0      Link encap:Ethernet  HWaddr 00:0a:35:00:22:01
          UP BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
          Interrupt:31

eth1      Link encap:Ethernet  HWaddr 00:0a:35:00:00:01
          inet addr:192.168.1.138  Bcast:192.168.1.255  Mask:255.255.255.0
          inet6 addr: 2001:569:58a2:2800:20a:35ff:fe00:1/64 Scope:Global
          UP BROADCAST RUNNING  MTU:1500  Metric:1
          RX packets:3343 errors:0 dropped:489 overruns:0 frame:0
          TX packets:79 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:528807 (516.4 KiB)  TX bytes:11146 (10.8 KiB)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:5 errors:0 dropped:0 overruns:0 frame:0
          TX packets:5 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:1208 (1.1 KiB)  TX bytes:1208 (1.1 KiB)
```

Now let’s test the 10G link, for this we are going to use iperf3, which was built-in the rootfs. but before to get the higher speed, we need to first modify the change of the MTU(Maximum Transmission Unit).

```bash
ifdown eth1
ifconfig eth1 mtu 9000 up
ifup eth1
```

Now we need to also change the MTU for the interface of the target, so if you are using Linux you need to execute the same command on your terminal. However if you are windows, you need to go to “Control Panel\Network and Internet\Network and Sharing Center” and select your 10Gbps network adapter and change the interface to be enabled to received Jumbo Packages.

## Support

For support, email phamvanduongqxth@gmail.com
Thanks !!!

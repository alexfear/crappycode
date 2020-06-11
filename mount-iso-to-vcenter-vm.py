#!/usr/bin/python3
from pyVim.connect import SmartConnect, Disconnect
from pyVmomi import vim, vmodl
import ssl
si = SmartConnect(host="",user="",pwd="",port=443,sslContext=ssl._create_unverified_context())
rootFolder = si.content.rootFolder
dc =
vm =
ds =
isoName = ''
isoPath = '['+ds.name+']'+isoName
editDevice = vim.vm.device.VirtualDeviceSpec.Operation('edit')
connectIso = vim.vm.device.VirtualDevice.ConnectInfo(connected=True,startConnected=True)
isoBacking = vim.vm.device.VirtualCdrom.IsoBackingInfo(datastore=ds,fileName=isoPath)
#todo: 16000 and 15000 are used as an example and as the default value
virtualCd = vim.vm.device.VirtualCdrom(backing=isoBacking,key=16000,controllerKey=15000,connectable=connectIso)
deviceConfigSpec = vim.vm.device.VirtualDeviceSpec(device=virtualCd,operation=editDevice)
vmConfigSpec = vim.vm.ConfigSpec(deviceChange=[deviceConfigSpec])
vm.ReconfigVM_Task(spec=vmConfigSpec)

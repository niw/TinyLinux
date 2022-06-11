//
//  Command.swift
//  TinyLinux
//
//  Created by Yoshimasa Niwa on 1/12/21.
//

import ArgumentParser
import Foundation
import Virtualization

@main
struct Command: ParsableCommand {
    @Option(help: "path to ungziped linux kernel.")
    var vmlinux: String

    @Option(help: "path to ramdisk.")
    var initrd: String?

    @Option(help: "kernel command-line parameters")
    var commandline: String = "console=hvc0"

    @Option(help: "number of CPUs.")
    var cpuCount: Int = 1

    @Option(help: "memory size in megabyte")
    var memorySize: Int = 512

    @Option(help: "path to disk image")
    var image: [String] = []

    mutating func run() throws {
        let bootLoader = VZLinuxBootLoader(kernelURL: URL(fileURLWithPath: vmlinux))
        if let initrd = initrd {
            bootLoader.initialRamdiskURL = URL(fileURLWithPath: initrd)
        }
        bootLoader.commandLine = commandline

        let standardInput = FileHandle.standardInput
        var attributes = termios()
        tcgetattr(standardInput.fileDescriptor, &attributes)
        attributes.c_iflag &= ~tcflag_t(ICRNL)
        attributes.c_lflag &= ~tcflag_t(ICANON | ECHO)
        tcsetattr(standardInput.fileDescriptor, TCSANOW, &attributes)

        let standardOutput = FileHandle.standardOutput

        let serialPort = VZVirtioConsoleDeviceSerialPortConfiguration()
        serialPort.attachment = VZFileHandleSerialPortAttachment(
            fileHandleForReading: standardInput,
            fileHandleForWriting: standardOutput
        )

        let entropyDevice = VZVirtioEntropyDeviceConfiguration()
        let memoryBalloonDevice = VZVirtioTraditionalMemoryBalloonDeviceConfiguration()

        let storageDevices = try image.map { image -> VZVirtioBlockDeviceConfiguration in
            let attachment = try VZDiskImageStorageDeviceAttachment(url: URL(fileURLWithPath: image), readOnly: true)
            return VZVirtioBlockDeviceConfiguration(attachment: attachment)
        }

        let networkDevice = VZVirtioNetworkDeviceConfiguration()
        networkDevice.attachment = VZNATNetworkDeviceAttachment()

        let configuration = VZVirtualMachineConfiguration()
        configuration.bootLoader = bootLoader
        configuration.memorySize = UInt64(memorySize * 1024 * 1024)
        configuration.cpuCount = cpuCount
        configuration.entropyDevices = [entropyDevice]
        configuration.memoryBalloonDevices = [memoryBalloonDevice]
        configuration.networkDevices = [networkDevice]
        configuration.serialPorts = [serialPort]
        configuration.storageDevices = storageDevices

        try configuration.validate()

        let machine = VZVirtualMachine(configuration: configuration)
        machine.start { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                print(error)
            }
        }

        RunLoop.main.run()
    }
}

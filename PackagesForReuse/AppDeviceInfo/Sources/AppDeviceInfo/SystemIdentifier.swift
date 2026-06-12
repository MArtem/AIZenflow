import Foundation

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

enum SystemIdentifier {
    static func machineIdentifier() -> String {
        #if canImport(Darwin) || canImport(Glibc)
        var systemInfo = utsname()
        guard uname(&systemInfo) == 0 else {
            return "unknown"
        }
        var machine = systemInfo.machine
        let capacity = MemoryLayout.size(ofValue: machine)
        return withUnsafePointer(to: &machine) { pointer in
            pointer.withMemoryRebound(to: CChar.self, capacity: capacity) { reboundPointer in
                String(cString: reboundPointer)
            }
        }
        #else
        return "unknown"
        #endif
    }

    static func architectureIdentifier() -> String {
        #if arch(arm64)
        return "arm64"
        #elseif arch(x86_64)
        return "x86_64"
        #elseif arch(arm)
        return "arm"
        #elseif arch(i386)
        return "i386"
        #else
        return "unknown"
        #endif
    }
}

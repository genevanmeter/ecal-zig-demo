
const std = @import("std");

const ecal = @cImport({
    @cInclude("ecal/ecalc.h");
});


pub fn main() !void {
    
    const version_str = ecal.eCAL_GetVersionString();
    const version_date_str = ecal.eCAL_GetVersionDateString();
   
    std.debug.print("eCAL Version {s}\n", .{version_str});
    std.debug.print("eCAL Build Date {s}\n", .{version_date_str});


    _ = ecal.eCAL_Initialize(0, null, "minimal_pub", ecal.eCAL_Init_Default);

    const publisher = ecal.eCAL_Pub_New();

    _ = ecal.eCAL_Pub_Create(publisher, "Hello", "base:std::string", "", 0);

             
    var count: u32 = 0;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    while( ecal.eCAL_Ok() == 1)
    {
        const message = try std.fmt.allocPrint(allocator, "Hello from Zig {}", .{count}); 

        defer allocator.free(message);

        
        const msg_len: c_int = @intCast(message.len);
        _ = ecal.eCAL_Pub_Send(publisher, message.ptr, msg_len, -1);


        ecal.eCAL_Process_SleepMS(100);

        count += 1;
    }
    _ = ecal.eCAL_Finalize(ecal.eCAL_Init_All);
}


//! Copyright (c) 2024-2025 Theodore Sackos
//! SPDX-License-Identifier: AGPL-3.0-or-later

const std = @import("std");

// The LuaJIT C API
const c = @import("c");

pub fn main() !void {
    var alloc = std.heap.page_allocator;

    const ud = try alloc.create(std.mem.Allocator);
    defer alloc.destroy(ud);
    ud.* = alloc;

    const L: *c.lua_State = @ptrCast(c.lua_newstate(NativeAllocator.alloc, ud));
    defer c.lua_close(L);

    c.luaL_openlibs(L);

    const stdin = std.io.getStdIn();
    const stdout = std.io.getStdOut();

    var window: [1025]u8 = undefined;
    const buf: []u8 = window[0..1024];

    while (true) {
        try stdout.writeAll("> ");

        var input = try stdin.reader().readUntilDelimiter(buf, '\n');
        if (input.len == 0) continue;
        // Make it a null terminated string.
        window[input.len + 1] = 0;
        input = window[0 .. input.len + 1 :0];

        if (std.mem.eql(u8, input, "exit")) break;

        if (c.luaL_dostring(L, input.ptr)) {
            var len: usize = undefined;
            const s = c.lua_tolstring(L, -1, &len);
            std.debug.print("Error: {s}\n", .{s});
            continue;
        }
    }
}

const max = @alignOf(std.c.max_align_t);
const NativeAllocator = struct {
    fn alloc(ud: ?*anyopaque, ptr: ?*anyopaque, osize: usize, nsize: usize) callconv(.c) ?*align(max) anyopaque {
        const allocator: *std.mem.Allocator = @ptrCast(@alignCast(ud.?));
        const aligned_ptr = @as(?[*]align(max) u8, @ptrCast(@alignCast(ptr)));
        if (aligned_ptr) |p| {
            if (nsize != 0) {
                const old_mem = p[0..osize];
                return (allocator.realloc(old_mem, nsize) catch return null).ptr;
            }

            allocator.free(p[0..osize]);
            return null;
        } else {
            // Malloc case
            return (allocator.alignedAlloc(u8, max, nsize) catch return null).ptr;
        }
    }
};

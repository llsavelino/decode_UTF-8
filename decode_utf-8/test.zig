const std = @import("std");
const decodeRune = @import("main.zig").decodeRune;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    const TestCase = struct {
        label: []const u8,
        input: []const u8,
    };

    const tests = [_]TestCase{
        .{ .label = "ASCII     ", .input = "A" },
        .{ .label = "2-byte    ", .input = "¢" },
        .{ .label = "3-byte    ", .input = "ह" },
        .{ .label = "4-byte    ", .input = "𐍈" },
        .{ .label = "Invalid 1 ", .input = "\xF8" }, // prefixo inválido
        .{ .label = "Invalid 2 ", .input = "\xE0\x80\x80" }, // overlong (U+0000 codificado com 3 bytes)
        .{ .label = "Surrogate ", .input = "\xED\xA0\x80" }, // U+D800 (metade de par substituto)
        .{ .label = "Too Big   ", .input = "\xF4\x90\x80\x80" }, // U+110000 (fora do limite)
    };

    for (tests) |tc| {
        const result = decodeRune(tc.input);
        try stdout.print("{s} | ", .{tc.label});
        try stdout.print("bytes = [");
        for (tc.input) |b| {
            try stdout.print("0x{X:0>2} ", .{b});
        }
        try stdout.print("]  r = {} U+{X:0>4} s = {} err = {s}\n", .{ result.r, result.r, result.s, result.err orelse "NULL" });
    }
}

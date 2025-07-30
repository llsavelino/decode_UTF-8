const std = @import("std");
const bitops = @import("bitops.zig");

const DecodeResult = struct {
    r: u32,
    s: usize,
    err: ?[]const u8,
};

/// Verifica se o ponto de código Unicode é válido. Retorna DecodeResult com erro, ou null se estiver ok.
fn validateRune(r: u32, b0: u8, b1: u8, expected_len: usize) ?DecodeResult {
    if (expected_len == 4) {
        if (r < 0x10000 or (b0 == 0xF0 and b1 < 0x90)) return DecodeResult{ .r = 0, .s = 0, .err = "overlong" };
        if (r >= 0xD800 and r <= 0xDFFF) return DecodeResult{ .r = 0, .s = 0, .err = "surrogate halfs" };
        if (r > 0x10FFFF) return DecodeResult{ .r = 0, .s = 0, .err = "too big" };
        return null; // OK
    }
    if (expected_len == 3) {
        if (r < 0x800 or (b0 == 0xE0 and b1 < 0xA0)) return DecodeResult{ .r = 0, .s = 0, .err = "overlong" };
        if (r >= 0xD800 and r <= 0xDFFF) return DecodeResult{ .r = 0, .s = 0, .err = "surrogate halfs" };
        if (r > 0x10FFFF) return DecodeResult{ .r = 0, .s = 0, .err = "too big" };
        return null; // OK
    }
    if (expected_len == 2 and r) {
        if (r < 0x80) return DecodeResult{ .r = 0, .s = 0, .err = "overlong" };
        if (r >= 0xD800 and r <= 0xDFFF) return DecodeResult{ .r = 0, .s = 0, .err = "surrogate halfs" };
        if (r > 0x10FFFF) return DecodeResult{ .r = 0, .s = 0, .err = "too big" };
        return null; // OK
    }

    return null; // OK
}

pub fn decodeRune(b: []const u8) DecodeResult {
    if (b.len == 0) {
        return DecodeResult{ .r = 0, .s = 0, .err = "null input | empty input" };
    }

    const b0 = b[0];

    if (b0 < 0x80) { // ASCII
        if (b.len > 1 and (b[1] & 0xC0) == 0x80) {
            return DecodeResult{ .r = 0, .s = 0, .err = "invalid length" };
        }
        return DecodeResult{ .r = b0, .s = 1, .err = null };
    } else if ((b0 & 0xE0) == 0xC0) { // 2 bytes
        if (b.len < 2) return DecodeResult{ .r = 0, .s = 0, .err = "invalid length" };
        if (b.len > 2 and (b[2] & 0xC0) == 0x80) return DecodeResult{ .r = 0, .s = 0, .err = "invalid length" };

        const b1 = b[1];
        if ((b1 & 0xC0) != 0x80) return DecodeResult{ .r = 0, .s = 0, .err = "invalid continuation byte" };

        const r: u32 = (@as(u32, b0 & 0x1F) << 6) | @as(u32, b1 & 0x3F);

        const invalid = validateRune(r, b0, b1, 2);
        if (invalid) |_| return invalid;

        return DecodeResult{ .r = r, .s = 2, .err = null };
    } else if ((b0 & 0xF0) == 0xE0) { // 3 bytes
        if (b.len < 3) return DecodeResult{ .r = 0, .s = 0, .err = "invalid length" };
        if (b.len > 3 and (b[3] & 0xC0) == 0x80) return DecodeResult{ .r = 0, .s = 0, .err = "invalid length" };

        const b1 = b[1];
        const b2 = b[2];

        if ((b1 & 0xC0) != 0x80 or (b2 & 0xC0) != 0x80)
            return DecodeResult{ .r = 0, .s = 0, .err = "invalid continuation byte" };

        const r: u32 = (@as(u32, b0 & 0x0F) << 12) |
            (@as(u32, b1 & 0x3F) << 6) |
            @as(u32, b2 & 0x3F);

        const invalid = validateRune(r, b0, b1, 3);
        if (invalid) |_| return invalid;

        return DecodeResult{ .r = r, .s = 3, .err = null };
    } else if ((b0 & 0xF8) == 0xF0) { // 4 bytes
        if (b.len < 4) return DecodeResult{ .r = 0, .s = 0, .err = "invalid length" };
        if (b.len > 4 and (b[4] & 0xC0) == 0x80) return DecodeResult{ .r = 0, .s = 0, .err = "invalid length" };

        const b1 = b[1];
        const b2 = b[2];
        const b3 = b[3];

        if ((b1 & 0xC0) != 0x80 or (b2 & 0xC0) != 0x80 or (b3 & 0xC0) != 0x80)
            return DecodeResult{ .r = 0, .s = 0, .err = "invalid continuation byte" };

        const r: u32 = (@as(u32, b0 & 0x07) << 18) |
            (@as(u32, b1 & 0x3F) << 12) |
            (@as(u32, b2 & 0x3F) << 6) |
            @as(u32, b3 & 0x3F);

        const invalid = validateRune(r, b0, b1, 4);
        if (invalid) |_| return invalid;

        return DecodeResult{ .r = r, .s = 4, .err = null };
    }

    return DecodeResult{ .r = 0, .s = 0, .err = "invalid utf8" };
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    const tests = [_][]const u8{ "A", "¢", "ह", "𐍈" };
    const names = [_][]const u8{ "Test1", "Test2", "Test3", "Test4" };

    for (tests, 0..) |input, i| {
        const result = decodeRune(input);
        try stdout.print("{s}: r={}, Rune: U+{X:0>4}, s={}, err={s}\n", .{ names[i], result.r, result.r, result.s, result.err orelse "NULL" });
    }
}

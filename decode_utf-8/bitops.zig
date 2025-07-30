const std = @import("std");

/// Retorna o valor Unicode de dois bytes UTF-8, ou 0 se qualquer ponteiro for nulo.
pub fn bytes2_utf8(x: ?*const u8, y: ?*const u8) u32 {
    if (x == null or y == null)
        return 0;

    return (@as(u32, x.?.*) & 0x1F) << 6 |
        (@as(u32, y.?.*) & 0x3F);
}

/// Retorna o valor Unicode de três bytes UTF-8, ou 0 se qualquer ponteiro for nulo.
pub fn bytes3_utf8(x: ?*const u8, y: ?*const u8, z: ?*const u8) u32 {
    if (x == null or y == null or z == null)
        return 0;

    return (@as(u32, x.?.*) & 0x0F) << 12 |
        (@as(u32, y.?.*) & 0x3F) << 6 |
        (@as(u32, z.?.*) & 0x3F);
}

/// Retorna o valor Unicode de quatro bytes UTF-8, ou 0 se qualquer ponteiro for nulo.
pub fn bytes4_utf8(x: ?*const u8, y: ?*const u8, z: ?*const u8, w: ?*const u8) u32 {
    if (x == null or y == null or z == null or w == null)
        return 0;

    return (@as(u32, x.?.*) & 0x07) << 18 |
        (@as(u32, y.?.*) & 0x3F) << 12 |
        (@as(u32, z.?.*) & 0x3F) << 6 |
        (@as(u32, w.?.*) & 0x3F);
}

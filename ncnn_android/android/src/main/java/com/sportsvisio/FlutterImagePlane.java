package com.sportsvisio;

import java.nio.ByteBuffer;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

public class FlutterImagePlane {
    /// Bytes representing this plane.
    public byte[] bytes;

    /// The row stride for this color plane, in bytes.
    public int bytesPerRow;

    /// The distance between adjacent pixel samples in bytes, when available.
    public int bytesPerPixel;

    public FlutterImagePlane(byte[] bytes, int bytesPerRow, int bytesPerPixel) {
        this.bytes = bytes;
        this.bytesPerRow = bytesPerRow;
        this.bytesPerPixel = bytesPerPixel;
    }

    public static FlutterImagePlane fromMap(Map<String, Object> map) {
        int bytesPerRow = (int) Objects.requireNonNull(map.get("bytesPerRow"), "bytesPerRow is required");
        int bytesPerPixel = (int) Objects.requireNonNull(map.get("bytesPerPixel"), "bytesPerPixel is required");
        byte[] bytes = (byte[]) Objects.requireNonNull(map.get("bytes"), "bytes is required");

        return new FlutterImagePlane(
                bytes,
                bytesPerRow,
                bytesPerPixel
        );
    }

    public byte[] getBytes() {
        return bytes;
    }

    public int getRowStride() {
        return bytesPerRow;
    }

    public int getPixelStride() {
        return bytesPerPixel;
    }

    public ByteBuffer getByteBuffer() {
        return ByteBuffer.wrap(bytes);
    }

    public Map<String, Object> toMap() {
        Map<String, Object> map = new HashMap<>();
        map.put("bytes", bytes);
        map.put("bytesPerRow", bytesPerRow);
        map.put("bytesPerPixel", bytesPerPixel);
        return map;
    }
}

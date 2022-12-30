package com.sportsvisio;

import android.graphics.Color;
import android.graphics.RectF;

import java.util.HashMap;
import java.util.Random;

public class Box {
    private final int labelId;
    private final float score;
    public float x0, y0, x1, y1;

    public Box(float x0, float y0, float x1, float y1, int labelId, float score) {
        this.x0 = x0;
        this.y0 = y0;
        this.x1 = x1;
        this.y1 = y1;
        this.labelId = labelId;
        this.score = score;
    }

    public RectF getRect() {
        return new RectF(x0, y0, x1, y1);
    }

    public float getScore() {
        return score;
    }

    public int getColor() {
        Random random = new Random(labelId);
        return Color.argb(255, random.nextInt(256), random.nextInt(256), random.nextInt(256));
    }

    public HashMap<String, Object> toMap() {
        HashMap<String, Object> map = new HashMap<>();
        map.put("x0", x0);
        map.put("y0", y0);
        map.put("x1", x1);
        map.put("y1", y1);
        map.put("labelId", labelId);
        map.put("score", score);
        return map;
    }
}

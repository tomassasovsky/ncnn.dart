// Copyright (c) 2022, SportsVisio, Inc.
// https://sportsvisio.com/
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

package com.sportsvisio;

public class OpenPoseKeyPoint {
    public float[] x;
    public float[] y;
    public float pointScore;

    public OpenPoseKeyPoint(float[] x, float[] y, float pointScore) {
        this.x = x;
        this.y = y;
        this.pointScore = pointScore;
    }

    public float[] getX() {
        return x;
    }

    public void setX(float[] x) {
        this.x = x;
    }

    public float[] getY() {
        return y;
    }

    public void setY(float[] y) {
        this.y = y;
    }

    public float getPointScore() {
        return pointScore;
    }

    public void setPointScore(float pointScore) {
        this.pointScore = pointScore;
    }

}

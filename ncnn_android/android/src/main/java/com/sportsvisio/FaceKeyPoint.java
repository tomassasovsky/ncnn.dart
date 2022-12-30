// Copyright (c) 2022, SportsVisio, Inc.
// https://sportsvisio.com/
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

package com.sportsvisio;

class FaceKeyPoint {
    public float x, y;

    public FaceKeyPoint(float x, float y) {
        this.x = x;
        this.y = y;
    }

    public float getX() {
        return x;
    }

    public void setX(float x) {
        this.x = x;
    }

    public float getY() {
        return y;
    }

    public void setY(float y) {
        this.y = y;
    }

}

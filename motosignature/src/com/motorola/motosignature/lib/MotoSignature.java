/*
 * SPDX-License-Identifier: Apache-2.0
 */

package com.motorola.motosignature.lib;

/** Stand-in for Moto's signature library, required by MotCamera2. */
public final class MotoSignature {
    private static final MotoSignature INSTANCE = new MotoSignature();

    private MotoSignature() {}

    public static MotoSignature getInstance() {
        return INSTANCE;
    }

    public boolean isMotorolaDevice() {
        return true;
    }
}

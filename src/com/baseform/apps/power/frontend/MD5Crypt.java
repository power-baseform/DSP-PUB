/*
 * Baseform
 * Copyright (C) 2018  Baseform
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

package com.baseform.apps.power.frontend;

import java.security.MessageDigest;
import java.util.Random;

public final class MD5Crypt {
    private static final String SALTCHARS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
    private static final String itoa64 = "./0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";

    public MD5Crypt() {
    }

    private static String to64(long v, int size) {
        StringBuffer result = new StringBuffer();

        while(true) {
            --size;
            if(size < 0) {
                return result.toString();
            }

            result.append("./0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz".charAt((int)(v & 63L)));
            v >>>= 6;
        }
    }

    private static void clearbits(byte[] bits) {
        for(int i = 0; i < bits.length; ++i) {
            bits[i] = 0;
        }

    }

    private static int bytes2u(byte inp) {
        return inp & 255;
    }

    public static String crypt(String password) {
        StringBuffer salt = new StringBuffer();
        Random randgen = new Random();

        while(salt.length() < 8) {
            int index = (int)(randgen.nextFloat() * (float)"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890".length());
            salt.append("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890".substring(index, index + 1));
        }

        return crypt(password, salt.toString());
    }

    public static String crypt(String password, String salt) {
        String magic = "$1$";
        if(salt.startsWith(magic)) {
            salt = salt.substring(magic.length());
        }

        if(salt.indexOf(36) != -1) {
            salt = salt.substring(0, salt.indexOf(36));
        }

        if(salt.length() > 8) {
            salt = salt.substring(0, 8);
        }

        MD5Crypt.MD5 ctx = new MD5Crypt.MD5();
        ctx.update(password.getBytes());
        ctx.update(magic.getBytes());
        ctx.update(salt.getBytes());
        MD5Crypt.MD5 ctx1 = new MD5Crypt.MD5();
        ctx1.update(password.getBytes());
        ctx1.update(salt.getBytes());
        ctx1.update(password.getBytes());
        byte[] finalState = ctx1.digest();

        int i;
        int c;
        for(i = password.length(); i > 0; i -= 16) {
            for(c = 0; c < (i > 16?16:i); ++c) {
                ctx.update(finalState[c]);
            }
        }

        clearbits(finalState);

        for(i = password.length(); i != 0; i >>>= 1) {
            if((i & 1) != 0) {
                ctx.update(finalState[0]);
            } else {
                ctx.update(password.getBytes()[0]);
            }
        }

        finalState = ctx.digest();

        for(i = 0; i < 1000; ++i) {
            ctx1 = new MD5Crypt.MD5();
            if((i & 1) != 0) {
                ctx1.update(password.getBytes());
            } else {
                for(c = 0; c < 16; ++c) {
                    ctx1.update(finalState[c]);
                }
            }

            if(i % 3 != 0) {
                ctx1.update(salt.getBytes());
            }

            if(i % 7 != 0) {
                ctx1.update(password.getBytes());
            }

            if((i & 1) != 0) {
                for(c = 0; c < 16; ++c) {
                    ctx1.update(finalState[c]);
                }
            } else {
                ctx1.update(password.getBytes());
            }

            finalState = ctx1.digest();
        }

        StringBuffer result = new StringBuffer();
        result.append(magic);
        result.append(salt);
        result.append("$");
        long l = (long)(bytes2u(finalState[0]) << 16 | bytes2u(finalState[6]) << 8 | bytes2u(finalState[12]));
        result.append(to64(l, 4));
        l = (long)(bytes2u(finalState[1]) << 16 | bytes2u(finalState[7]) << 8 | bytes2u(finalState[13]));
        result.append(to64(l, 4));
        l = (long)(bytes2u(finalState[2]) << 16 | bytes2u(finalState[8]) << 8 | bytes2u(finalState[14]));
        result.append(to64(l, 4));
        l = (long)(bytes2u(finalState[3]) << 16 | bytes2u(finalState[9]) << 8 | bytes2u(finalState[15]));
        result.append(to64(l, 4));
        l = (long)(bytes2u(finalState[4]) << 16 | bytes2u(finalState[10]) << 8 | bytes2u(finalState[5]));
        result.append(to64(l, 4));
        l = (long)bytes2u(finalState[11]);
        result.append(to64(l, 2));
        clearbits(finalState);
        return result.toString();
    }

    public static void main(String[] args) {
        System.out.println(crypt(args[0], args[1]));
    }

    public static class MD5 extends MessageDigest implements Cloneable {
        private final int[] W;
        private long bytecount;
        private int A;
        private int B;
        private int C;
        private int D;

        public MD5() {
            super("MD5");
            this.W = new int[16];
            this.engineReset();
        }

        public Object clone() {
            return new MD5Crypt.MD5(this);
        }

        private MD5(MD5Crypt.MD5 copy) {
            this();
            this.bytecount = copy.bytecount;
            this.A = copy.A;
            this.B = copy.B;
            this.C = copy.C;
            this.D = copy.D;
            System.arraycopy(copy.W, 0, this.W, 0, 16);
        }

        public int engineGetDigestLength() {
            return 20;
        }

        public void engineReset() {
            this.bytecount = 0L;
            this.A = 1732584193;
            this.B = -271733879;
            this.C = -1732584194;
            this.D = 271733878;

            for(int i = 0; i < 16; ++i) {
                this.W[i] = 0;
            }

        }

        public void engineUpdate(byte b) {
            int i = (int)this.bytecount % 64;
            int shift = (3 - i % 4) * 8;
            int idx = i / 4;
            this.W[idx] = this.W[idx] & ~(255 << shift) | (b & 255) << shift;
            if(++this.bytecount % 64L == 0L) {
                this.munch();
            }

        }

        public void engineUpdate(byte[] bytes, int off, int len) {
            if(len < 0) {
                throw new ArrayIndexOutOfBoundsException();
            } else {
                int end = off + len;

                while(off < end) {
                    this.engineUpdate(bytes[off++]);
                }

            }
        }

        public byte[] engineDigest() {
            long bitcount = this.bytecount * 8L;
            this.engineUpdate((byte) -128);

            while((int)this.bytecount % 64 != 56) {
                this.engineUpdate((byte) 0);
            }

            this.W[14] = this.SWAP((int)(-1L & bitcount));
            this.W[15] = this.SWAP((int)(-1L & bitcount >>> 32));
            this.bytecount += 8L;
            this.munch();
            this.A = this.SWAP(this.A);
            this.B = this.SWAP(this.B);
            this.C = this.SWAP(this.C);
            this.D = this.SWAP(this.D);
            byte[] result = new byte[]{(byte)(this.A >>> 24), (byte)(this.A >>> 16), (byte)(this.A >>> 8), (byte)this.A, (byte)(this.B >>> 24), (byte)(this.B >>> 16), (byte)(this.B >>> 8), (byte)this.B, (byte)(this.C >>> 24), (byte)(this.C >>> 16), (byte)(this.C >>> 8), (byte)this.C, (byte)(this.D >>> 24), (byte)(this.D >>> 16), (byte)(this.D >>> 8), (byte)this.D};
            this.engineReset();
            return result;
        }

        private int F(int X, int Y, int Z) {
            return X & Y | ~X & Z;
        }

        private int G(int X, int Y, int Z) {
            return X & Z | Y & ~Z;
        }

        private int H(int X, int Y, int Z) {
            return X ^ Y ^ Z;
        }

        private int I(int X, int Y, int Z) {
            return Y ^ (X | ~Z);
        }

        private int rotateLeft(int i, int count) {
            return i << count | i >>> 32 - count;
        }

        private int FF(int a, int b, int c, int d, int k, int s, int i) {
            a += this.F(b, c, d) + k + i;
            return b + this.rotateLeft(a, s);
        }

        private int GG(int a, int b, int c, int d, int k, int s, int i) {
            a += this.G(b, c, d) + k + i;
            return b + this.rotateLeft(a, s);
        }

        private int HH(int a, int b, int c, int d, int k, int s, int i) {
            a += this.H(b, c, d) + k + i;
            return b + this.rotateLeft(a, s);
        }

        private int II(int a, int b, int c, int d, int k, int s, int i) {
            a += this.I(b, c, d) + k + i;
            return b + this.rotateLeft(a, s);
        }

        private int SWAP(int n) {
            return (255 & n) << 24 | (n & '\uff00') << 8 | n >>> 8 & '\uff00' | n >>> 24;
        }

        private void munch() {
            int[] X = new int[16];

            for(int j = 0; j < 16; ++j) {
                X[j] = this.SWAP(this.W[j]);
            }

            int AA = this.A;
            int BB = this.B;
            int CC = this.C;
            int DD = this.D;
            this.A = this.FF(this.A, this.B, this.C, this.D, X[0], 7, -680876936);
            this.D = this.FF(this.D, this.A, this.B, this.C, X[1], 12, -389564586);
            this.C = this.FF(this.C, this.D, this.A, this.B, X[2], 17, 606105819);
            this.B = this.FF(this.B, this.C, this.D, this.A, X[3], 22, -1044525330);
            this.A = this.FF(this.A, this.B, this.C, this.D, X[4], 7, -176418897);
            this.D = this.FF(this.D, this.A, this.B, this.C, X[5], 12, 1200080426);
            this.C = this.FF(this.C, this.D, this.A, this.B, X[6], 17, -1473231341);
            this.B = this.FF(this.B, this.C, this.D, this.A, X[7], 22, -45705983);
            this.A = this.FF(this.A, this.B, this.C, this.D, X[8], 7, 1770035416);
            this.D = this.FF(this.D, this.A, this.B, this.C, X[9], 12, -1958414417);
            this.C = this.FF(this.C, this.D, this.A, this.B, X[10], 17, -42063);
            this.B = this.FF(this.B, this.C, this.D, this.A, X[11], 22, -1990404162);
            this.A = this.FF(this.A, this.B, this.C, this.D, X[12], 7, 1804603682);
            this.D = this.FF(this.D, this.A, this.B, this.C, X[13], 12, -40341101);
            this.C = this.FF(this.C, this.D, this.A, this.B, X[14], 17, -1502002290);
            this.B = this.FF(this.B, this.C, this.D, this.A, X[15], 22, 1236535329);
            this.A = this.GG(this.A, this.B, this.C, this.D, X[1], 5, -165796510);
            this.D = this.GG(this.D, this.A, this.B, this.C, X[6], 9, -1069501632);
            this.C = this.GG(this.C, this.D, this.A, this.B, X[11], 14, 643717713);
            this.B = this.GG(this.B, this.C, this.D, this.A, X[0], 20, -373897302);
            this.A = this.GG(this.A, this.B, this.C, this.D, X[5], 5, -701558691);
            this.D = this.GG(this.D, this.A, this.B, this.C, X[10], 9, 38016083);
            this.C = this.GG(this.C, this.D, this.A, this.B, X[15], 14, -660478335);
            this.B = this.GG(this.B, this.C, this.D, this.A, X[4], 20, -405537848);
            this.A = this.GG(this.A, this.B, this.C, this.D, X[9], 5, 568446438);
            this.D = this.GG(this.D, this.A, this.B, this.C, X[14], 9, -1019803690);
            this.C = this.GG(this.C, this.D, this.A, this.B, X[3], 14, -187363961);
            this.B = this.GG(this.B, this.C, this.D, this.A, X[8], 20, 1163531501);
            this.A = this.GG(this.A, this.B, this.C, this.D, X[13], 5, -1444681467);
            this.D = this.GG(this.D, this.A, this.B, this.C, X[2], 9, -51403784);
            this.C = this.GG(this.C, this.D, this.A, this.B, X[7], 14, 1735328473);
            this.B = this.GG(this.B, this.C, this.D, this.A, X[12], 20, -1926607734);
            this.A = this.HH(this.A, this.B, this.C, this.D, X[5], 4, -378558);
            this.D = this.HH(this.D, this.A, this.B, this.C, X[8], 11, -2022574463);
            this.C = this.HH(this.C, this.D, this.A, this.B, X[11], 16, 1839030562);
            this.B = this.HH(this.B, this.C, this.D, this.A, X[14], 23, -35309556);
            this.A = this.HH(this.A, this.B, this.C, this.D, X[1], 4, -1530992060);
            this.D = this.HH(this.D, this.A, this.B, this.C, X[4], 11, 1272893353);
            this.C = this.HH(this.C, this.D, this.A, this.B, X[7], 16, -155497632);
            this.B = this.HH(this.B, this.C, this.D, this.A, X[10], 23, -1094730640);
            this.A = this.HH(this.A, this.B, this.C, this.D, X[13], 4, 681279174);
            this.D = this.HH(this.D, this.A, this.B, this.C, X[0], 11, -358537222);
            this.C = this.HH(this.C, this.D, this.A, this.B, X[3], 16, -722521979);
            this.B = this.HH(this.B, this.C, this.D, this.A, X[6], 23, 76029189);
            this.A = this.HH(this.A, this.B, this.C, this.D, X[9], 4, -640364487);
            this.D = this.HH(this.D, this.A, this.B, this.C, X[12], 11, -421815835);
            this.C = this.HH(this.C, this.D, this.A, this.B, X[15], 16, 530742520);
            this.B = this.HH(this.B, this.C, this.D, this.A, X[2], 23, -995338651);
            this.A = this.II(this.A, this.B, this.C, this.D, X[0], 6, -198630844);
            this.D = this.II(this.D, this.A, this.B, this.C, X[7], 10, 1126891415);
            this.C = this.II(this.C, this.D, this.A, this.B, X[14], 15, -1416354905);
            this.B = this.II(this.B, this.C, this.D, this.A, X[5], 21, -57434055);
            this.A = this.II(this.A, this.B, this.C, this.D, X[12], 6, 1700485571);
            this.D = this.II(this.D, this.A, this.B, this.C, X[3], 10, -1894986606);
            this.C = this.II(this.C, this.D, this.A, this.B, X[10], 15, -1051523);
            this.B = this.II(this.B, this.C, this.D, this.A, X[1], 21, -2054922799);
            this.A = this.II(this.A, this.B, this.C, this.D, X[8], 6, 1873313359);
            this.D = this.II(this.D, this.A, this.B, this.C, X[15], 10, -30611744);
            this.C = this.II(this.C, this.D, this.A, this.B, X[6], 15, -1560198380);
            this.B = this.II(this.B, this.C, this.D, this.A, X[13], 21, 1309151649);
            this.A = this.II(this.A, this.B, this.C, this.D, X[4], 6, -145523070);
            this.D = this.II(this.D, this.A, this.B, this.C, X[11], 10, -1120210379);
            this.C = this.II(this.C, this.D, this.A, this.B, X[2], 15, 718787259);
            this.B = this.II(this.B, this.C, this.D, this.A, X[9], 21, -343485551);
            this.A += AA;
            this.B += BB;
            this.C += CC;
            this.D += DD;
        }
    }
}
